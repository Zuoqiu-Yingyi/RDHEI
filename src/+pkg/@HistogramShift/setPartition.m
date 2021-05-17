% setPartition.m
function varargout = setPartition(self, setIndex, varargin)
    % setPartition - 集合划分
    %
    % Syntax: varargout = setPartition(self, setIndex, varargin);
    % @param setIndex 集合索引 {1, 2}
    % @return varargout
    %   nargout == 0: 不返回
    %   nargout == 1: 返回刚刚更新的集合
    %   nargout == 2: 返回两个集合
    % Long description

    p = inputParser; % 函数的输入解析器

    % 必需的由位置确定的位置参数
    p.addRequired('setIndex', @(A) A == 1 || A == 2);

    p.parse(setIndex, varargin{:}); % 解析参数

    self.sets{p.Results.setIndex}(:, 3) = arrayfun(...
        @(I, J) self.image_post(I, J), ...
        self.sets{p.Results.setIndex}(:, 1), ...
        self.sets{p.Results.setIndex}(:, 2));

    switch nargout
        case 1
            varargout = {self.sets{p.Results.setIndex}};
        case 2
            varargout = {self.sets{:}};
        otherwise
            varargout = {};
    end

end
