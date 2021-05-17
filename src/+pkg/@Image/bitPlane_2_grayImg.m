% bitPlane_2_grayImg.m
function grayImg = bitPlane_2_grayImg(bitPlane, varargin)
    % 将位平面转换为灰度图
    % @param bitPlane tensor[img_height, img_width, bit] 位平面, bit为1时为最低位, bit为8时为最高位
    %
    % @return grayImg matrix 灰度图像

    img_size = size(bitPlane);
    grayImg = zeros(img_size(1), img_size(2));

    for bit = 1:8
        grayImg = bitset(grayImg, bit, bitPlane(:, :, bit));
    end

    grayImg = uint8(grayImg);

end
