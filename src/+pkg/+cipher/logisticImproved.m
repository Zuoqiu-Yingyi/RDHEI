% logisticImproved.m
function chaoticVariables = logisticImproved(x, N, k, varargin)
    % Ligistic 混沌变量序列改进生成方法
    % @param x double 初值, 取值范围(0, 1]
    % @param N uint 迭代次数
    % @param k double 控制参量(可选, 默认为 3001)
    %
    % @return chaoticVariables vector 每一次迭代的迭代值

    switch nargin
        case 2
            k = 3001;
        otherwise

    end

    chaoticVariables = zeros(N, 1);

    for index = 1:N
        x = k * x * (1 - x);
        x = x - floor(x);
        chaoticVariables(index) = x;
    end

end
