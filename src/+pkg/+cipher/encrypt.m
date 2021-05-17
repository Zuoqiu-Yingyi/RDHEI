function cipherImage = encrypt(plainImage, logisticIterator1, logisticIterator2, varargin)
    % encrypt - 图像加密
    %
    % @param plainImage pkg.Image 明文图片
    % @param logisticIterator1 pkg.itertor.* 混沌序列迭代器对象1
    % @param logisticIterator2 pkg.itertor.* 混沌序列迭代器对象2
    %
    % @return cipherImage pkg.Image 密文图片

    p = inputParser; % 函数的输入解析器

    % 必需的由位置确定的位置参数
    p.addRequired('plainImage', @(A) isa(A, 'pkg.Image'));
    p.addRequired('logisticIterator1', @(A) isa(A, 'pkg.iterator.Iterator'));
    p.addRequired('logisticIterator2', @(A) isa(A, 'pkg.iterator.Iterator'));

    p.parse(plainImage, logisticIterator1, logisticIterator2, varargin{:}); % 解析参数

    %% STEP-1 图像分块

    H_sub = 2; % 子图高
    W_sub = 2; % 子图宽

    P = p.Results.plainImage.getGraySubImg(H_sub, W_sub);

    [h, w] = size(P);

    N_sub = H_sub * W_sub;
    n = h * w;

    % 产生混沌序列
    A1 = (p.Results.logisticIterator1.getMat(3, n) < 0.5);
    A2 = (p.Results.logisticIterator1.getMat(5, n, N_sub) < 0.5);

    % 生成置乱密钥
    [scramblingEncryptionMap, ~] = pkg.cipher.generateScramblingMap(p.Results.logisticIterator2, n);
    % [~, scramblingEncryptionMap] = sort(p.Results.logisticIterator2.getMat(n, 1));

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
    for index_i = 1:n
        C(scramblingEncryptionMap(index_i)) = P(index_i);
    end

    %% 加密结束, 转换格式
    cipherImage = pkg.Image(uint8(cell2mat(C)));
end
