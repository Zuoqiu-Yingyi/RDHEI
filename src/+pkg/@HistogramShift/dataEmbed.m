% dataEmbed.m
function varargout = dataEmbed(self, setIndex, iter, varargin)
    % dataEmbed - 数据嵌入
    %
    % Syntax: varargout = dataEmbed(self, setIndex, iter, varargin);
    % @param setIndex 集合索引 {1, 2} (位置参数-必要)
    % @param iter 比特流迭代器 (位置参数-必要)
    % @param inputLength 预定义的输入大小(单位: bit) (名称-值对组参数-可选)
    % @return varargout
    %   nargout == 0: 不返回
    % Long description

    p = inputParser; % 函数的输入解析器

    % 必需的由位置确定的位置参数
    p.addRequired('setIndex', @(A) A == 1 || A == 2);
    p.addRequired('iter', @(A) isa(A, 'matlab.compiler.mlspark.util.Iterator'));

    % 可选的由名称-值对组确定的参数
    p.addParameter('inputLength', 30000 .* self.level, @(A) isreal(A));

    p.parse(setIndex, iter, varargin{:}); % 解析参数

    input_data = zeros(p.Results.inputLength, 1, 'logical');
    input_i = 0;

    for index = 1:size(self.sets{p.Results.setIndex}, 1)
        e = self.sets{p.Results.setIndex}(index, 6);
        p_ = self.sets{p.Results.setIndex}(index, 4);

        if p.Results.iter.hasnext % 数据未填充完毕

            if e >= ceil(self.level ./ 2)
                e_ = e + ceil(self.level ./ 2);
            elseif e <= -ceil((self.level + 1) ./ 2)
                e_ = e - floor(self.level ./ 2);
            elseif e >= 0 && e <= floor((self.level - 1) ./ 2)
                e_ = e + e + p.Results.iter.previewnext;
            elseif e <= -1 && e >= -floor(self.level ./ 2)
                e_ = e + e + 1 - p.Results.iter.previewnext;
            end

            p__ = floor(p_ - e_ + 0.5);

            if p__ > 255 || p__ < 0 % 像素值会溢出
                self.mark(...
                    self.sets{p.Results.setIndex}(index, 1), ...
                    self.sets{p.Results.setIndex}(index, 2)) = true;
                e_ = e;
            else % 像素值不会溢出

                if e >= 0 && e <= floor((self.level - 1) ./ 2)
                    e_ = e + e + p.Results.iter.getnext;

                    input_i = input_i + 1;
                    input_data(input_i) = e_;
                elseif e <= -1 && e >= -floor(self.level ./ 2)
                    e_ = e + e + 1 - p.Results.iter.getnext;

                    input_i = input_i + 1;
                    input_data(input_i) = e_;
                end

            end

        else
            e_ = e;
        end

        p__ = floor(p_ - e_ + 0.5);
        self.sets{p.Results.setIndex}(index, 7) = e_;
        self.sets{p.Results.setIndex}(index, 5) = p__;
        self.image_post(...
            self.sets{p.Results.setIndex}(index, 1), ...
            self.sets{p.Results.setIndex}(index, 2)) = p__;
    end

    switch nargout
        case 1
            varargout = {input_data(1:input_i)};
        case 2
            varargout = {input_data(1:input_i), self.sets{p.Results.setIndex}};
        case 3
            varargout = cell([{input_data(1:input_i)}, self.sets]);
        otherwise
            varargout = {};
    end

end
