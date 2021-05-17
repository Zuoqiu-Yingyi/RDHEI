% Image.m
classdef Image < handle
    % 图片类
    % 具有图片的常用属性与处理方式

    properties
        % 属性
        img; % 原图片
        gray_img = []; % 灰度图片
        gray_img_energy = -inf; % 图片能量
        gray_img_max = -inf; % 图片最大值
        bin_img = []; % 二值图片
        dft_mat = []; % DFT矩阵
        dct_mat = []; % DCT矩阵
        dwt_cell = {}; % DWT元胞 {cA,cH,cV,cD}
        bit_plane = []; % 灰度图片位平面
        stat_hist = []; % 统计直方图
    end

    properties (Dependent = true)
        img_size; % 原图片尺寸
        gray_img_size; % 灰度图片尺寸
    end

    methods
        % 构造方法
        function self = Image(img)

            if ischar(img)
                self.img = imread(img);
            else
                self.img = img;
            end

        end

    end

    methods (Static = true)
        % 静态方法
        % 获得图片的 zia-zag 的扫描结果
        zigZag = getZigZag(img, varargin);

        % 位平面 -> 灰度图
        grayImg = bitPlane_2_grayImg(bitPlane, varargin);

    end

    methods
        % 一般方法
        % 获得指定宽高的子图张量
        subImgs = getGraySubImg(self, subImgWidth, subImgHeight, fillContent, varargin)

        % 复制构造
        varargout = copy(self, varargin);

        % 方差 计算
        function SE = SE(self, processedImg, varargin)
            SE = sum(sum((self.gray_img - processedImg.gray_img).^2));
        end

        % 均方差 计算
        function MSE = MSE(self, processedImg, varargin)
            MSE = SE(self, processedImg, varargin) / numel(self.gray_img);
        end

        % 归一化均方差 计算
        function NMSE = NMSE(self, processedImg, varargin)
            NMSE = SE(self, processedImg, varargin) / self.gray_img_energy;
        end

        % 信噪比 计算
        function SNR = SNR(self, processedImg, varargin)
            SNR = 10 * log10(self.gray_img_energy / SE(self, processedImg, varargin));
        end

        % 峰值信噪比 计算
        function PSNR = PSNR(self, processedImg, varargin)
            PSNR = 10 * log10((double(self.gray_img_max).^2) / MSE(self, processedImg, varargin));
        end

        % 图像保真度 计算
        function IF = IF(self, processedImg, varargin)
            IF = 1 - NMSE(self, processedImg, varargin);
        end

    end

    methods
        % getter 方法
        function img = get.img(self)
            img = self.img;
        end

        function grayImg = get.gray_img(self)

            if isempty(self.gray_img)

                if ndims(self.img) == 3
                    self.gray_img = rgb2gray(self.img);
                else
                    self.gray_img = self.img;
                end

            end

            grayImg = self.gray_img;
        end

        % 图片能量 计算
        function imgEnergy = get.gray_img_energy(self)

            if self.gray_img_energy < 0
                self.gray_img_energy = sum(sum(double(self.gray_img).^2));
            end

            imgEnergy = self.gray_img_energy;
        end

        function imgMax = get.gray_img_max(self)

            if self.gray_img_max == -inf
                self.gray_img_max = max(max(self.gray_img));
            end

            imgMax = self.gray_img_max;
        end

        function binImg = get.bin_img(self)

            if isempty(self.bin_img)
                self.bin_img = imbinarize(self.gray_img);
            end

            binImg = self.bin_img;
        end

        function dftMat = get.dft_mat(self)

            if isempty(self.dft_mat)
                self.dft_mat = fft2(self.gray_img);
            end

            dftMat = self.dft_mat;
        end

        function dctMat = get.dct_mat(self)

            if isempty(self.dct_mat)
                self.dct_mat = dct2(self.gray_img);
            end

            dctMat = self.dct_mat;
        end

        function dwtCell = get.dwt_cell(self)

            if isempty(self.dwt_cell)
                [cA, cH, cV, cD] = dwt2(self.gray_img, 'db1');
                self.dwt_cell = {cA, cH, cV, cD};
            end

            dwtCell = self.dwt_cell;
        end

        function bitPlane = get.bit_plane(self)

            if isempty(self.bit_plane)

                for i = 1:8
                    self.bit_plane(:, :, i) = bitget(self.gray_img, i);
                end

                self.bit_plane = logical(self.bit_plane);

            end

            bitPlane = self.bit_plane;
        end

        function statHist = get.stat_hist(self)

            if isempty(self.stat_hist)
                self.stat_hist = zeros(256, 1);
                temp_img = self.gray_img;
                [m, n] = size(temp_img);

                for i = 1:m

                    for j = 1:n
                        grayscale = temp_img(i, j);
                        self.stat_hist(grayscale + 1) = self.stat_hist(grayscale + 1) + 1;
                    end

                end

            end

            statHist = self.stat_hist;
        end

        function imgSize = get.img_size(self)
            imgSize = size(self.img);
        end

        function grayImgSize = get.gray_img_size(self)
            grayImgSize = size(self.gray_img);
        end

    end

end
