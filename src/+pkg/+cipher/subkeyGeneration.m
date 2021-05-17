% subkeyGeneration.m
function [x, y, u, r] = subkeyGeneration(passPhrase, varargin)
    % subkeyGeneration - Description
    %
    % Syntax: [x, y, u, r] =  subkeyGeneration(passPhrase, 'x0', 0, 'y0', 0, 'u0', 0, 'r0', 0, varargin)
    % 
    % @param passPhrase str 用于生成密钥的口令 (位置参数-必要)
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
    p.addRequired('passPhrase', @(A) ischar(A));

    % 可选的由名称-值对组确定的参数
    p.addParameter('x0', 0, @(A) isreal(A));
    p.addParameter('y0', 0, @(A) isreal(A));
    p.addParameter('u0', 0, @(A) isreal(A));
    p.addParameter('r0', 0, @(A) isreal(A));

    p.parse(passPhrase, varargin{:}); % 解析参数

    a = java.security.MessageDigest.getInstance('sha-256');

    a.update(unicode2native(p.Results.passPhrase));
    hash_uint8 = typecast(a.digest, 'uint8');

    temp = hash_uint8(1);

    for index = 2:8
        temp = bitxor(temp, hash_uint8(index));
    end

    x = p.Results.x0 + mod(double(temp) / 256, 1);

    temp = hash_uint8(9);

    for index = 10:16
        temp = bitxor(temp, hash_uint8(index));
    end

    y = p.Results.y0 + mod(double(temp) / 256, 1);

    temp = hash_uint8(17);

    for index = 18:24
        temp = bitxor(temp, hash_uint8(index));
    end

    u = mod(p.Results.u0 + double(temp) / 256, 1);

    temp = hash_uint8(25);

    for index = 26:32
        temp = bitxor(temp, hash_uint8(index));
    end

    r = mod(p.Results.r0 + double(temp) / 256, 1);
end
