% subkeyGeneration.m
function [x, y, u, r] = subkeyGeneration(hashCode, varargin)
    % subkeyGeneration - Description
    %
    % Syntax: [x, y, u, r] =  subkeyGeneration(hashCode, 'x0', 0, 'y0', 0, 'u0', 0, 'r0', 0, varargin)
    %
    % @param hashCode uint8 散列码 (位置参数-必要)
    % @param x0 double 密钥生成控制参数 (名称-值对组参数-可选)
    % @param y0 double 密钥生成控制参数 (名称-值对组参数-可选)
    % @param u0 double 密钥生成控制参数 (名称-值对组参数-可选)
    % @param r0 double 密钥生成控制参数 (名称-值对组参数-可选)
    %
    % @return x double 混沌序列控制参数 (名称-值对组参数-可选)
    % @return y double 混沌序列控制参数 (名称-值对组参数-可选)
    % @return u double 混沌序列控制参数 (名称-值对组参数-可选)
    % @return r double 混沌序列控制参数 (名称-值对组参数-可选)

    p = inputParser; % 函数的输入解析器

    % 必需的由位置确定的位置参数
    p.addRequired('hashCode', @(A) isa(A, 'uint8') && length(A) >= 32);

    % 可选的由名称-值对组确定的参数
    p.addParameter('x0', 0, @(A) isreal(A));
    p.addParameter('y0', 0, @(A) isreal(A));
    p.addParameter('u0', 0, @(A) isreal(A));
    p.addParameter('r0', 0, @(A) isreal(A));

    p.parse(hashCode, varargin{:}); % 解析参数

    temp_1 = p.Results.hashCode(1);

    for index = 2:8
        temp_1 = bitxor(temp_1, p.Results.hashCode(index));
    end

    temp_2 = p.Results.hashCode(9);

    for index = 10:16
        temp_2 = bitxor(temp_2, p.Results.hashCode(index));
    end

    temp_1 = double(temp_1);
    temp_2 = double(temp_2);

    x = p.Results.x0 + mod(((temp_1 * 256) + temp_2) / 65536, 1);
    y = p.Results.y0 + mod(temp_2 / 256, 1);

    temp_1 = p.Results.hashCode(17);

    for index = 18:24
        temp_1 = bitxor(temp_1, p.Results.hashCode(index));
    end

    temp_2 = p.Results.hashCode(25);

    for index = 26:32
        temp_2 = bitxor(temp_2, p.Results.hashCode(index));
    end

    temp_1 = double(temp_1);
    temp_2 = double(temp_2);

    u = mod(p.Results.u0 + ((temp_1 * 256) + temp_2) / 65536, 1);
    r = mod(p.Results.r0 + temp_2 / 256, 1);
end
