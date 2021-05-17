% Author: LiShuangHe
% Time: 2021-05-06
% 图像加密模块

clc;
clear all#
%% 图像输入
[X, map] = imread('.\images\Lena.tiff');   % 图像读入
figure(1)
imshow(X)         % 单步测试使用
[H, W] = size(X);   % 统计图像的长宽
% fprintf('%i * %i 的灰度图像加载成功\n', H, W);


%% STEP1 图像分块
Z = mat2cell(X, 2 * ones(1, 256), 2 * ones(1, 256));
B0 = zeros(1, 512 * 512);  
for i = 1 : 256
    for j = 1 : 256
        temp = reorder(cell2mat(Z(i, j))); % reorder()为自定义2 * 2排序函数
        for k = 1 : 4
            B0(1, k + 4 * (j - 1)+  4 * 256 * (i - 1)) = temp(1, k); 
        end
    end
end

%% STEP2 高位加密
B1 = zeros(1, 512 * 512); 

% 产生混沌序列(接口设置位置***)
iter1 = pkg.iterator.LogisticSineIterator(0.25);
iter2 = pkg.iterator.LogisticSineIterator(0.75);
A1 = (iter1.getMat(3 * 256 * 256, 1) < 0.5);
A2 = (iter1.getMat(4 * 5 * 256 * 256, 1) < 0.5);
[~, p] = sort(iter2.getMat(1, 256 * 256));

% 高位异或加密
for i = 1 : (256 * 256)
    temp = bitshift(A1( (i - 1) * 3 + 1) + 2 * A1((i - 1) * 3 + 2) + 4 * A1((i - 1) * 3 + 3), 5);  % (???)2向左移动五位
    for j = 1 : 4
        B1( (i - 1 ) * 4 + j) = bitxor(B0( (i - 1 ) * 4 + j), temp);    % 块内第j号像素
    end
end


%% STEP3 低位加密
B2 = zeros(1, 512 * 512); 

% 低位异或加密 #TODO有问题 
for i = 1 : (256 * 256)
        s1 = bitget(B1(1, (i - 1) * 4 + 1), 8:-1:6);
        s2 = bitget(B1(1, (i - 1) * 4 + 2), 8:-1:6);
        s3 = bitget(B1(1, (i - 1) * 4 + 3), 8:-1:6);
        s4 = bitget(B1(1, (i - 1) * 4 + 4), 8:-1:6);
        if( sum(s1 ~= s2) == 0 && sum(s3 ~= s4) == 0 && sum(s2 ~= s3) == 0)
            % 注释以下三行可以将满足高三位相等的块黑色
            for j = 1:4
                B2(1, (i - 1 ) * 4 + j) = B1(1, (i - 1 ) * 4 + j);
            end

            continue;
        end
        
        for j = 1 : 4
            temp = A2( (i - 1) * 20 + (j - 1) * 5 + 1) + 2 * A2((i - 1) * 20 + (j - 1) * 5 + 2) + 4 * A2((i - 1) * 20 + (j - 1) * 5 + 3) + 8 * A2((i - 1) * 20 + (j - 1) * 5 + 4) + 16 * A2((i - 1) * 20 + (j - 1) * 5 + 5);
            B2(1, (i - 1 ) * 4 + j) = bitxor(B1(1, (i - 1 ) * 4 + j), temp);
        end
end
% fprintf('%i %i %i %i %i', A2(21), A2(22), A(23), A(24), A(25));debug使用

%% STEP4 图像块置乱
% 设置置乱序列长度
n = 256 * 256;

% 块置乱操作
B3 = mat2cell(B2, 1, 4 * ones(1, 256 * 256));
B4 = cell(1, 256 * 256);
for i = 1:n
    B4(1, i) = B3(1, p(i));
end

%% 加密结束, 转换格式
B5 = zeros(512, 512);
for i = 1:256
    for j = 1:256
        temp = cell2mat(B4(1, (i - 1) * 256 + j));
        B5((i - 1) * 2 + 1, (j - 1) * 2 + 1) = temp(1, 1);
        B5((i - 1) * 2 + 1, (j - 1) * 2 + 2) = temp(1, 2);
        B5((i - 1) * 2 + 2, (j - 1) * 2 + 1) = temp(1, 3);
        B5((i - 1) * 2 + 2, (j - 1) * 2 + 2) = temp(1, 4);
    end
end
B6 = uint8(B5);
figure(2)
imshow(uint8(B6))


%% 解密部分
% 假设接收方接收到加密过程的
% 加密图像B5、置乱秘钥P、混沌序列A和A2
%% STEP1 图像分块
Zc = mat2cell(B5, 2 * ones(1, 256), 2 * ones(1, 256));
C0 = zeros(1, 512 * 512);  
for i = 1 : 256
    for j = 1 : 256
        temp = reorder(cell2mat(Zc(i, j)));
        for k = 1 : 4
            C0(1, k + 4 * (j - 1)+  4 * 256 * (i - 1)) = temp(1, k); 
        end
    end
end


%% STEP2 块的逆置乱操作
% 设置逆置乱序列长度
n = 256 * 256;

% 块逆置乱操作
C1 = mat2cell(C0, 1, 4 * ones(1, 256 * 256));
C2 = cell(1, 256 * 256);
for i = 1:n
    C2(1, p(i)) = C1(1, i);
end

%% STPE3 低位解密
C3 = cell2mat(C2);
C4 = zeros(1, 512 * 512); 

% 低位异或加密
for i = 1 : (256 * 256)
        s1 = bitget(C3(1, (i - 1) * 4 + 1), 8:-1:6);
        s2 = bitget(C3(1, (i - 1) * 4 + 2), 8:-1:6);
        s3 = bitget(C3(1, (i - 1) * 4 + 3), 8:-1:6);
        s4 = bitget(C3(1, (i - 1) * 4 + 4), 8:-1:6);
        if( sum(s1 ~= s2) == 0 && sum(s3 ~= s4) == 0 && sum(s2 ~= s3) == 0)
            for j = 1:4
                C4(1, (i - 1 ) * 4 + j) = C3(1, (i - 1 ) * 4 + j);
            end
            continue;
        end
        
        for j = 1 : 4
            temp = A2( (i - 1) * 20 + (j - 1) * 5 + 1) + 2 * A2((i - 1) * 20 + (j - 1) * 5 + 2) + 4 * A2((i - 1) * 20 + (j - 1) * 5 + 3) + 8 * A2((i - 1) * 20 + (j - 1) * 5 + 4) + 16 * A2((i - 1) * 20 + (j - 1) * 5 + 5);
            C4(1, (i - 1 ) * 4 + j) = bitxor(C3(1, (i - 1 ) * 4 + j), temp);
        end
end


%% STEP4 高位解密

C5 = zeros(1, 512 * 512); 

% 高位异或加密
for i = 1 : (256 * 256)
    temp = bitshift(A1( (i - 1) * 3 + 1) + 2 * A1((i - 1) * 3 + 2) + 4 * A1((i - 1) * 3 + 3), 5);  % (???)2向左移动五位
    for j = 1 : 4
        C5( (i - 1 ) * 4 + j) = bitxor(C4( (i - 1 ) * 4 + j), temp);    % 块内第j号像素
    end
end



%%  解密结束, 转换格式
C6 = mat2cell(C5, 1, 4 * ones(1, 256 * 256));

C7 = zeros(512, 512);
for i = 1:256
    for j = 1:256
        temp = cell2mat(C6(1, (i - 1) * 256 + j));
        C7((i - 1) * 2 + 1, (j - 1) * 2 + 1) = temp(1, 1);
        C7((i - 1) * 2 + 1, (j - 1) * 2 + 2) = temp(1, 2);
        C7((i - 1) * 2 + 2, (j - 1) * 2 + 1) = temp(1, 3);
        C7((i - 1) * 2 + 2, (j - 1) * 2 + 2) = temp(1, 4);
    end
end
C8 = uint8(C7);
figure(3)
imshow(C8)

figure(4)
imshowpair(X, C8, 'montage'); % 并列显示图像
sum(X ~= C8, 'all')
cipherImage_1 = pkg.Image(B6);