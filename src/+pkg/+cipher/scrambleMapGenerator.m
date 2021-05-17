% scrambleMapGenerator.m
function [scramblingEncryptionMap, scramblingDecryptionMap] = scrambleMapGenerator(LogisticIterator, keyLength, varargin)
    % 使用混沌序列迭代器生成置换映射
    %
    % @param LogisticIterator Iterator 混沌序列迭代器对象 (序列分布在[0, 1]之间)
    % @param keyLength uint 密钥长度
    %
    % @return scramblingEncryptionMap vector 置乱加密映射
    % @return scramblingDecryptionMap vector 置乱解密映射

    scramblingEncryptionMap = (1:keyLength)'; % 打乱前的加密映射(列优先向量)

    % 使用不会原地置换的 Fisher–Yates shuffle 算法 进行置乱
    for index = 1:keyLength
        % 当前元素与之后随机一个元素交换
        temp = scramblingEncryptionMap(index);
        rand_index = keyLength - floor(LogisticIterator.getnext * (keyLength - index));
        scramblingEncryptionMap(index) = scramblingEncryptionMap(rand_index);
        scramblingEncryptionMap(rand_index) = temp;
    end

    [~, scramblingDecryptionMap] = sort(scramblingEncryptionMap); % 使用 sort 获得置换映射的逆映射

end
