% reorder.m
function b = reorder(a)
% input:2 * 2的矩阵
% do:特定排序
% output:1 * 4的矩阵（行向量）
[n, m] = size(a);
if(n ~= 2 && m ~= 2)
    error('Input array is NOT 2-by-2');
end

zigzag=[1 2 3 4];

aa = reshape(a',1,4); % 将输入2 * 2矩阵变成1 * 4的行向量
zigzagR = reshape(zigzag', 1, 4);
b = aa(zigzagR); % 对aa按照查表方式取元素
end