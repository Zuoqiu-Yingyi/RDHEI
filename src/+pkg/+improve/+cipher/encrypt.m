function [cipherImage, varargout] = encrypt(plainImage, passphrase, varargin)
    % encrypt - 图像加密
    %
    % @param plainImage pkg.Image 明文图片
    % @param passphrase str 口令 (位置参数-必要)
    % @param x0 double 密钥生成控制参数 (名称-值对组参数-可选)
    % @param y0 double 密钥生成控制参数 (名称-值对组参数-可选)
    % @param u0 double 密钥生成控制参数 (名称-值对组参数-可选)
    % @param r0 double 密钥生成控制参数 (名称-值对组参数-可选)
    % @param k double 混沌序列迭代器控制参数 (名称-值对组参数-可选)
    % @param N uint 混沌序列迭代器初始迭代次数 (名称-值对组参数-可选)
    %
    % @return cipherImage pkg.Image 密文图片

    p = inputParser; % 函数的输入解析器

    % 必需的由位置确定的位置参数
    p.addRequired('plainImage', @(A) isa(A, 'pkg.Image'));
    p.addRequired('passphrase', @(A) ischar(A));

    % 可选的由名称-值对组确定的参数
    p.addParameter('x0', 0, @(A) isreal(A));
    p.addParameter('y0', 0, @(A) isreal(A));
    p.addParameter('u0', 0, @(A) isreal(A));
    p.addParameter('r0', 0, @(A) isreal(A));
    p.addParameter('k', 18, @(A) isreal(A));
    p.addParameter('N', 50, @(A) isreal(A));

    p.parse(plainImage, passphrase, varargin{:}); % 解析参数

    %% STEP-1 图像分块

    H_sub = 2; % 子图高
    W_sub = 2; % 子图宽

    P = p.Results.plainImage.getGraySubImg(H_sub, W_sub);

    [h, w] = size(P);

    N_sub = H_sub * W_sub;
    n = h * w;

    % 产生混沌序列1
    reference_pixel_LSB = zeros(n, 1, 'uint8'); % 递增序列1

    for index_i = 1:n

        % [数组中的唯一值 - MATLAB unique - MathWorks 中国](https://ww2.mathworks.cn/help/matlab/ref/double.unique.html?s_tid=doc_ta#bs_6vpd-1-C)
        if numel(unique(bitshift(P{index_i}, -5))) == 1 % 四个像素的 MSB 相等
            reference_pixel_LSB(index_i) = bitshift(P{index_i}(1), 3); % 提取低五位特征值
        end

    end

    reference_pixel_LSB = sort(reference_pixel_LSB(:)); % 排序

    hmac_instance = pkg.utils.Mac('HmacSHA256', p.Results.passphrase);
    [x1, y1, u1, r1] = pkg.cipher.subkeyGeneration(...
        hmac_instance.doFinal(int2str(reference_pixel_LSB')), ...
        'x0', p.Results.x0, ...
        'y0', p.Results.y0, ...
        'u0', p.Results.u0, ...
        'r0', p.Results.r0);

    iter1 = pkg.iterator.LogisticSineIterator(x1, 'u', u1, 'k', p.Results.k, 'N', p.Results.N); % 混沌序列1生成器

    % 生成随机比特序列
    A1 = (iter1.getMat(3, n) < 0.5);
    A2 = (iter1.getMat(5, n, N_sub) < 0.5);

    %% STEP-2 高位异或加密
    for index_i = 1:n
        r = sum(bitset(0, (8:-1:6)', A1(:, index_i), 'uint8'));
        P{index_i} = bitxor(P{index_i}, r);
    end

    %% STEP-3 低位加密
    for index_i = 1:n

        % [数组中的唯一值 - MATLAB unique - MathWorks 中国](https://ww2.mathworks.cn/help/matlab/ref/double.unique.html?s_tid=doc_ta#bs_6vpd-1-C)
        if numel(unique(bitshift(P{index_i}, -5))) == 1 % 四个像素的 MSB 相等, LSB 不加密
        else % LSB 需加密

            for index_k = 1:N_sub
                r = sum(bitset(0, (5:-1:1)', A2(:, index_i, index_k), 'uint8'));
                P{index_i}(index_k) = bitxor(P{index_i}(index_k), r);
            end

        end

    end

    %% STEP-4 图像块置乱
    C = cell(h, w);

    % 获得排序后的参考像素
    reference_pixel = cellfun(@(A) A(1), P); % 递增序列2
    reference_pixel = sort(reference_pixel(:));
    varargout{1} = reference_pixel;

    % 生成置乱密钥
    hmac_instance = pkg.utils.Mac('HmacSHA256', p.Results.passphrase);
    [x2, ~, u2, ~] = pkg.cipher.subkeyGeneration(...
        hmac_instance.doFinal(int2str(reference_pixel')), ...
        'x0', x1, ...
        'y0', y1, ...
        'u0', u1, ...
        'r0', r1);
    iter2 = pkg.iterator.LogisticSineIterator(x2, 'u', u2, 'k', p.Results.k, 'N', p.Results.N); % 混沌序列2生成器
    [scramblingEncryptionMap, ~] = pkg.cipher.generateScramblingMap(iter2, n);
    varargout{2} = scramblingEncryptionMap;
    % [~, scramblingEncryptionMap] = sort(p.Results.logisticIterator2.getMat(n, 1));

    % 块置乱
    for index_i = 1:n
        C(scramblingEncryptionMap(index_i)) = P(index_i);
    end

    %% 加密结束, 转换格式
    cipherImage = pkg.Image(uint8(cell2mat(C)));
end
