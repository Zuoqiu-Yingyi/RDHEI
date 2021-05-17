% getGraySubImg.m
function subImgs = getGraySubImg(self, subImgHeight, subImgWidth, fillContent, varargin)
    % 获得指定宽高的子图张量(无法正好分隔时对边缘进行填充)
    % @param subImgHeight int 子图的高度
    % @param subImgWidth int 子图的宽度
    % @param fillContent int 切割子图时宽/高不足填充内容
    %
    % @return subImgs cell(2) 由子图组成的二维元胞数组

    switch nargin
        case 2
            subImgWidth = subImgHeight;
            fillContent = 0;
        case 3
            fillContent = 0;
        otherwise

    end

    [img_height, img_width] = size(self.gray_img); % 原图尺寸
    dif_width = mod(img_width, subImgWidth); % 待填充宽度
    dif_height = mod(img_height, subImgHeight); % 待填充高度

    % 填充后的图片矩阵
    filled_img = ones(img_height + dif_height, img_width + dif_width) * fillContent;
    filled_img(floor(dif_height / 2) + 1:floor(dif_height / 2) + img_height, floor(dif_width / 2) + 1:floor(dif_width / 2) + img_width) = self.gray_img;

    [filled_height, filled_width] = size(filled_img); % 填充后的图片宽高

    % [将数组转换为在元胞中包含子数组的元胞数组 - MATLAB mat2cell - MathWorks 中国](https://ww2.mathworks.cn/help/matlab/ref/mat2cell.html)
    subImgs = mat2cell(filled_img, ones(1, filled_height / subImgHeight) * subImgHeight, ones(1, filled_width / subImgWidth) * subImgWidth);
end
