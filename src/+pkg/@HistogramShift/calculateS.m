function varargout = calculateS(self, varargin)
    % 计算像素的四个方位权值 S1~S4
    varargout = cell(1, nargout); % 创建待返回的元胞数组 % 构造函数

    for index = 1:nargout
        varargout{index} = 0.5 - self.k .* varargin{index} .* (0.5 - 1);
    end

end
