% permutate.m
function afterPermutate = permutate(beforePermutate, permutateMap, varargin)
    % 置换操作
    %
    % @param beforePermutate vector 置换前向量
    % @param permutateMap vector 置换映射
    %
    % @return afterPermutate vector 置换后向量

    afterPermutate = zeros(size(beforePermutate));

    for index = 1:numel(beforePermutate)
        afterPermutate(permutateMap(index)) = beforePermutate(index);
    end

end
