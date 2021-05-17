% pixelPrediction.m
function varargout = pixelPrediction(self, setIndex, varargin)
    % pixelPrediction - 像素预测
    %
    % Syntax: varargout = pixelPrediction(self, setIndex, varargin);
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

    I = self.sets{p.Results.setIndex}(:, 1); % 获得集合V1中像素的行索引
    J = self.sets{p.Results.setIndex}(:, 2); % 获得集合V2中像素的列索引
    [A1, A2, A3, A4] = self.calculateA(I, J); % 计算像素p_{i, j}的四个相似性参数 A1~A4
    [S1, S2, S3, S4] = self.calculateS(A1, A2, A3, A4); % 计算像素的四个方位权值 S1~S4
    [s, t] = self.calculateST(S1, S2, S3, S4); % 计算二维空间距离参数 s' 与 t'
    [Hl, Hr, Vu, Vl] = self.calculateHV(I, J); % 计算梯度权系数 Hl, Hr, Vu, Vl
    [Whl, Whr, Wvu, Wul] = self.calculateW(s, t, Hl, Hr, Vu, Vl); % 计算预测权值 w_Hl, w_Hr, w_Vu, w_Vl
    self.sets{p.Results.setIndex}(:, 4) = self.calculateP(I, J, Whl, Whr, Wvu, Wul); % 计算预测像素值 p'
    self.sets{p.Results.setIndex}(:, 6) = self.calculateE(self.sets{p.Results.setIndex}(:, 3), self.sets{p.Results.setIndex}(:, 4)); % 计算预测误差 e

    switch nargout
        case 1
            varargout = {self.sets{p.Results.setIndex}};
        case 2
            varargout = {self.sets{:}};
        otherwise
            varargout = {};
    end

end
