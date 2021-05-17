function plainImage = decrypt(cipherImage, logisticIterator1, logisticIterator2, varargin)
    % encrypt - 图像加密
    %
    % @param cipherImage pkg.Image 密文图片
    % @param logisticIterator1 pkg.itertor.* 混沌序列迭代器对象1
    % @param logisticIterator2 pkg.itertor.* 混沌序列迭代器对象2
    %
    % @return cipherImage pkg.Image 密文图片

    p = inputParser; % 函数的输入解析器

    % 必需的由位置确定的位置参数
    p.addRequired('cipherImage', @(A) isa(A, 'pkg.Image'));
    p.addRequired('logisticIterator1', @(A) isa(A, 'pkg.iterator.Iterator'));
    p.addRequired('logisticIterator2', @(A) isa(A, 'pkg.iterator.Iterator'));

    p.parse(cipherImage, logisticIterator1, logisticIterator2, varargin{:}); % 解析参数

    %% STEP-1 图像分块

    H_sub = 2; % 子图高
    W_sub = 2; % 子图宽

    C = p.Results.cipherImage.getGraySubImg(H_sub, W_sub);

    [h, w] = size(C);

    N_sub = H_sub * W_sub;
    n = h * w;

    % 产生混沌序列
    A1 = (p.Results.logisticIterator1.getMat(3, n) < 0.5);
    A2 = (p.Results.logisticIterator1.getMat(5, n, N_sub) < 0.5);

    % 生成恢复密钥
    [~, scramblingDecryptionMap] = pkg.cipher.generateScramblingMap(p.Results.logisticIterator2, n);
    % [~, scramblingEncryptionMap] = sort(p.Results.logisticIterator2.getMat(n, 1));
    % [~, scramblingDecryptionMap] = sort(scramblingEncryptionMap);

    %% STEP-2 块的逆置乱操作
    P = cell(h, w);

    for index_i = 1:n
        P(scramblingDecryptionMap(index_i)) = C(index_i);
    end

    %% STPE-3 低位解密
    for index_i = 1:n

        % [数组中的唯一值 - MATLAB unique - MathWorks 中国](https://ww2.mathworks.cn/help/matlab/ref/double.unique.html?s_tid=doc_ta#bs_6vpd-1-C)
        if numel(unique(bitshift(P{index_i}, -5))) == 1 % 四个像素的 MSB 相等, LSB 未加密
        else % LSB 需解密

            for index_k = 1:N_sub
                r = sum(bitset(0, (5:-1:1)', A2(:, index_i, index_k), 'uint8'));
                P{index_i}(index_k) = bitxor(P{index_i}(index_k), r);
            end

        end

    end

    %% STEP-4 高位解密
    for index_i = 1:n
        r = sum(bitset(0, (8:-1:6)', A1(:, index_i), 'uint8'));
        P{index_i} = bitxor(P{index_i}, r);
    end

    %%  解密结束, 转换格式
    plainImage = pkg.Image(uint8(cell2mat(P)));
end
