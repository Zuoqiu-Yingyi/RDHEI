% logistic.m
function chaoticVariables = logistic(x, N, u, varargin)
    % Ligistic 混沌变量序列生成方法
    % @param x double 初值, 取值范围(0, 1]
    % @param N uint 迭代次数
    % @param u double 控制参量(可选, 默认为4-2^(-50))
    %
    % @return chaoticVariables vector 每一次迭代的迭代值

    switch nargin
        case 2
            u = 4 - 2^(-50);
        otherwise

    end

    chaoticVariables = zeros(N, 1);

    for index = 1:N
        x = u * x * (1 - x);
        chaoticVariables(index) = x;
    end

end
