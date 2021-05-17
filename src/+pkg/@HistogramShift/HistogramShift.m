% HistogramShift.m
classdef HistogramShift < handle

    properties % 公有属性
        % properties (SetAccess = protected) % 写受保护属性
        image_pre = []; % 处理前图片
        image_post = []; % 处理后图片
        level = 0; % 数据嵌入级别
        k = 0; % Warped Distance 算法修正因子 {1, 2}
        L = 0; % 灰度最大值(从1开始)
        alpha = 0; % 锐度参数 [0, 1]
        mark = []; % 像素标记
        sets = {}; % 两个用矩阵表示的集合
        % [i, j, e, p, p', p'']
        %   i: 原像素的行坐标
        %   j: 原像素的纵坐标
        %   p: 嵌入数据前的像素值
        %   p': 预测像素值
        %   p'': 嵌入数据后/提取数据后的像素值
        %   e: 预测误差
        %   e': 嵌入数据后/提取数据后的预测误差
    end

    properties % 公有属性

    end

    properties (Dependent = true) % 调用时实时计算的属性
        image_size; % 图片尺寸
    end

    methods (Static = true) % 静态方法
    end

    methods % 公开方法

        % 构造函数
        function self = HistogramShift(grayImage, varargin)
            % HistogramShift - 构造函数
            %
            % Syntax: self = HistogramShift(grayImage, 'level', 1, 'k', 1, 'L', 256, 'alpha', 0.3, 'mark', zeros(size(grayImage));
            % @param grayImage matrix 待处理的灰度图片 (位置参数-必要)
            % @param level uint 数据嵌入级别(填充直方图个数) (位置参数-可选)
            % @param k double Warped Distance 算法修正因子 (名称-值对组参数-可选)
            % @param L uint 灰度最大值(从1开始) (名称-值对组参数-可选)
            % @param alpha double 锐度参数 (名称-值对组参数-可选)
            % @param mark matrix(logical) 像素对应的标记位平面 (名称-值对组参数-可选)
            % @return self 实例化的对象
            % Long description

            p = inputParser; % 函数的输入解析器

            % 必需的由位置确定的位置参数
            p.addRequired('grayImage', @(A) isreal(A) && ismatrix(A));

            % 可选的由位置确定的参数
            p.addOptional('level', 1, @(A) isreal(A) && A >= 1);

            % 可选的由名称-值对组确定的参数
            p.addParameter('k', 1, @(A) isreal(A));
            p.addParameter('L', 256, @(A) isreal(A));
            p.addParameter('alpha', 0.3, @(A) isreal(A));
            p.addParameter('mark', zeros(size(grayImage), 'logical'), @(A) isreal(A) && ismatrix(A));

            p.parse(grayImage, varargin{:}); % 解析参数

            self.image_pre = p.Results.grayImage;
            self.image_post = double(p.Results.grayImage);
            self.level = p.Results.level;
            self.k = p.Results.k;
            self.L = p.Results.L;
            self.alpha = p.Results.alpha;
            self.mark = p.Results.mark;

            % if gpuDeviceCount >= 1 % GPU 加速
            %     self.image_post = gpuArray(self.image_post);
            % end

            self.initSets(); % 初始化集合

        end

        % 集合划分
        varargout = setPartition(self, setIndex, varargin);

        % 像素预测
        varargout = pixelPrediction(self, setIndex, varargin);

        % 数据嵌入
        varargout = dataEmbed(self, setIndex, iterator, varargin);

        % 数据提取
        varargout = dataExtract(self, setIndex, varargin);

        % getter 方法
        function image_size = get.image_size(self)
            image_size = size(self.image_pre);
        end

        % 计算像素p_{i, j}的四个相似性参数 A1~A4
        [A1, A2, A3, A4] = calculateA(self, I, J, varargin);
    
        % 计算像素的四个方位权值 S1~S4
        varargout = calculateS(self, varargin);
    
        % 计算二维空间距离参数 s' 与 t'
        [s, t] = calculateST(self, S1, S2, S3, S4, varargin);
    
        % 计算梯度权系数 Hl, Hr, Vu, Vl
        [Hl, Hr, Vu, Vl] = calculateHV(self, I, J, varargin);
    
        % 计算预测权值 w_Hl, w_Hr, w_Vu, w_Vl
        [Whl, Whr, Wvu, Wul] = calculateW(self, s, t, Hl, Hr, Vu, Vl, varargin);
    
        % 计算预测像素值 p'
        [p_] = calculateP(self, I, J, Whl, Whr, Wvu, Wul, varargin);
    
        % 计算预测误差 e
        [e] = calculateE(self, p, p_, varargin);
    end

    methods (Access = protected) % 受保护方法

        function initSets(self, varargin) % 初始化两个像素集合的索引
            [h, w] = size(self.image_pre); % 图片尺寸
            h = h - 4; % 需要索引的像素长度
            w = w - 4; % 需要索引的像素宽度
            column_length_1 = ceil(h / 2);
            column_length_2 = floor(h / 2);
            row_length_1 = ceil(w / 2);
            row_length_2 = floor(w / 2);

            set_length_1 = column_length_1 * row_length_1 + column_length_2 * row_length_2; % 集合1中的像素个数
            set_length_2 = column_length_2 * row_length_1 + column_length_1 * row_length_2; % 集合2中的像素个数

            set1 = zeros(set_length_1, 7);
            set2 = zeros(set_length_2, 7);

            set1_index = 1;
            set2_index = 1;
            i_index_1 = 1:2:h; % 每一列的索引(从1开始, 间距为2)
            i_index_2 = 2:2:h; % 每一列的索引(从2开始, 间距为2)

            for w_index = 1:2:w % 初始化集合中的像素索引
                set1((set1_index:set1_index + column_length_1 - 1), 1) = i_index_1 + 2;
                set1((set1_index:set1_index + column_length_1 - 1), 2) = w_index + 2;
                set1_index = set1_index + column_length_1;

                set2((set2_index:set2_index + column_length_2 - 1), 1) = i_index_2 + 2;
                set2((set2_index:set2_index + column_length_2 - 1), 2) = w_index + 2;
                set2_index = set2_index + column_length_2;

                set1((set1_index:set1_index + column_length_2 - 1), 1) = i_index_2 + 2;
                set1((set1_index:set1_index + column_length_2 - 1), 2) = w_index + 2 + 1;
                set1_index = set1_index + column_length_2;

                set2((set2_index:set2_index + column_length_1 - 1), 1) = i_index_1 + 2;
                set2((set2_index:set2_index + column_length_1 - 1), 2) = w_index + 2 + 1;
                set2_index = set2_index + column_length_1;
            end

            % if gpuDeviceCount >= 1 % GPU 加速
            %     set1 = gpuArray(set1);
            %     set2 = gpuArray(set2);
            % end

            self.sets = {set1, set2}; % 初始化集合
        end

    end

end
