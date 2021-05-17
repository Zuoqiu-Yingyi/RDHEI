% getZigZag.m
function zigZag = getZigZag(img, varargin)
    % 获得指定宽高的子图张量(无法正好分隔时对边缘进行填充)
    % @params img matrix 将要进行变换的矩阵(不要求宽高相等)
    %
    % @return zigZag vector 由子图生成的 zig-zag 扫描结果

    img_rot90 = rot90(img, 1); % 获得旋转 90 度的矩阵, 方便使用 diag 函数进行提取

    % 获得待扫描的对角线的起止坐标
    [scan_begin, scan_end] = size(img_rot90);
    scan_begin = -(scan_begin - 1);
    scan_end = scan_end - 1;

    zigZag = zeros(numel(img_rot90), 1); % 生成待返回的矩阵
    index = 1; % 指向待替换的 zig-zag 块的索引
    flag_flip = true; % 当前对角线是否需要翻转

    for k = scan_begin:scan_end
        temp = diag(img_rot90, k);
        index_step = numel(temp); % 移动步长

        if flag_flip% 颠倒对角线向量
            zigZag(index:(index + index_step - 1)) = flipud(temp);
        else % 不用颠倒对角线向量
            zigZag(index:(index + index_step - 1)) = temp;
        end

        flag_flip = ~flag_flip;
        index = index + index_step;
    end

end
