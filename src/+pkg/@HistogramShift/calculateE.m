function [e] = calculateE(self, p, p_, varargin)
    % 计算预测误差 e
    e = floor(p_ - p + 0.5);
end
