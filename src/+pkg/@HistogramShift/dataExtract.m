% dataExtract.m
function varargout = dataExtract(self, setIndex, varargin)
    % dataExtract - 数据提取
    %
    % Syntax: varargout = dataExtract(self, setIndex, varargin);
    % @param setIndex 集合索引 {1, 2} (位置参数-必要)
    % @param outputLength 预定义的输出大小 (名称-值对组参数-可选)
    % @return varargout
    %   nargout == 0: 不返回
    %   nargout == 1: 返回刚刚更新的集合
    %   nargout == 2: 返回两个集合
    % Long description

    p = inputParser; % 函数的输入解析器

    % 必需的由位置确定的位置参数
    p.addRequired('setIndex', @(A) A == 1 || A == 2);

    % 可选的由名称-值对组确定的参数
    p.addParameter('outputLength', 30000 .* self.level, @(A) isreal(A));

    p.parse(setIndex, varargin{:}); % 解析参数

    output_data = zeros(p.Results.outputLength, 1, 'logical');
    output_i = 0;

    for index = 1:size(self.sets{p.Results.setIndex}, 1)
        e = self.sets{p.Results.setIndex}(index, 6);
        p_ = self.sets{p.Results.setIndex}(index, 4);

        if ~self.mark(...
                self.sets{p.Results.setIndex}(index, 1), ...
                self.sets{p.Results.setIndex}(index, 2)) % 该像素平移

            if e >= 2 * ceil(self.level ./ 2)
                e_ = e - ceil(self.level ./ 2);
            elseif e <= -2 * floor(self.level ./ 2) - 1
                e_ = e + floor(self.level ./ 2);
            elseif e >= 0 && e < 2 * ceil(self.level ./ 2)
                output_i = output_i + 1;
                output_data(output_i) = logical(mod(e, 2));
                e_ = floor(e ./ 2);
            elseif e <= -1 && e > -2 * floor(self.level ./ 2) - 1
                output_i = output_i + 1;
                output_data(output_i) = logical(mod(e + 1, 2));
                e_ = ceil((e - 1) ./ 2);
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
            varargout = {output_data(1:output_i)};
        case 2
            varargout = {output_data(1:output_i), self.sets{p.Results.setIndex}};
        case 3
            varargout = cell([{output_data(1:output_i)}, self.sets]);
        otherwise
            varargout = {};
    end

end
