% func_log.m

function A = func_log(N)
% function:产生0, 1的长度为N的随机序列
% input: x为初值限定如下, N为产生序列长度
% 限定x 为初值(-1, 1)
% output: 数值范围为(-1, 1)的长度为N随机序列
%                向上取整, 输出为0或者1随机序列A
x = 0.36;
u = 2;
for i = 1:N
    x1 = 1 - u * x * x;
    A(i) = ceil(x1);
    x = x1;
end
