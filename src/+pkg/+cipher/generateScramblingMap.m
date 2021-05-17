% generateScramblingKey.m
function [scramblingEncryptionMap, scramblingDecryptionMap] = generateScramblingMap(chaoticIteratorObj, keyLength, preIterationNum, varargin)
    % 使用混沌序列迭代器生成置换映射
    %
    % @param chaoticIteratorObj Iterator 混沌序列迭代器对象
    % @param keyLength uint 密钥长度
    % @param preIterationNum uint 混沌序列预迭代次数(可选, 默认为50)
    %
    % @return scramblingEncryptionMap vector 置乱加密映射
    % @return scramblingDecryptionMap vector 置乱解密映射

    switch nargin
        case 2
            preIterationNum = 50;
        otherwise

    end

    % 首先对混沌序列迭代器进行预迭代
    for index = 1:preIterationNum
        chaoticIteratorObj.getnext;
    end

    scramblingEncryptionMap = (1:keyLength)'; % 打乱前的加密映射(列优先向量)
    % 使用不会原地置换的 Fisher–Yates shuffle 算法 进行置乱
    for index = 1:keyLength
        % 当前元素与之后随机一个元素交换
        temp = scramblingEncryptionMap(index);
        rand_index = keyLength - floor(chaoticIteratorObj.getnext * (keyLength - index));
        scramblingEncryptionMap(index) = scramblingEncryptionMap(rand_index);
        scramblingEncryptionMap(rand_index) = temp;
    end

    [~, scramblingDecryptionMap] = sort(scramblingEncryptionMap); % 使用 sort 获得置换映射的逆映射

end
