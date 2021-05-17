% reorder.m
function b = reorder(a)
% input:2 * 2�ľ���
% do:�ض�����
% output:1 * 4�ľ�����������
[n, m] = size(a);
if(n ~= 2 && m ~= 2)
    error('Input array is NOT 2-by-2');
end

zigzag=[1 2 3 4];

aa = reshape(a',1,4); % ������2 * 2������1 * 4��������
zigzagR = reshape(zigzag', 1, 4);
b = aa(zigzagR); % ��aa���ղ��ʽȡԪ��
end