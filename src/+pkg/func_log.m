% func_log.m

function A = func_log(N)
% function:����0, 1�ĳ���ΪN���������
% input: xΪ��ֵ�޶�����, NΪ�������г���
% �޶�x Ϊ��ֵ(-1, 1)
% output: ��ֵ��ΧΪ(-1, 1)�ĳ���ΪN�������
%                ����ȡ��, ���Ϊ0����1�������A
x = 0.36;
u = 2;
for i = 1:N
    x1 = 1 - u * x * x;
    A(i) = ceil(x1);
    x = x1;
end
