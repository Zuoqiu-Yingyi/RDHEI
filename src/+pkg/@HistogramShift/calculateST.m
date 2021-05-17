function [s, t] = calculateST(self, S1, S2, S3, S4, varargin)
    % 计算二维空间距离参数 s' 与 t'
    s = (S1 + (S2 - S1) .* S3) ./ (1 - (S4 - S3) .* (S2 - S1));
    t = (S3 + (S4 - S3) .* S1) ./ (1 - (S4 - S3) .* (S2 - S1));
    theta = pi ./ 4; % 仿射变换旋转角度
    A = [cos(theta), -sin(theta); sin(theta), cos(theta)]; % 仿射变换系数矩阵
    b = [sqrt(2) ./ 2; 0]; % 仿射变换平移矩阵
    a = sqrt(2) ./ 2; % 仿射变换缩放系数
    temp = a .* (A * [s'; t'] + b); % [s'; t']
    s = temp(1, :)';
    t = temp(2, :)';
end
