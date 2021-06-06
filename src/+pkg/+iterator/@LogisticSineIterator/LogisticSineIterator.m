% LogisticSineIterator.m
classdef LogisticSineIterator < pkg.iterator.Iterator
    % 结合 Logistic 与 Sine 映射的混沌变量序列生成迭代器类
    properties
        % 属性
        x0; % 迭代器初值
        x; % 当前迭代值
        r; % 控制参量
        u; % 控制参量
        k; % 控制参量
        N0; % 初始迭代次数
        N; % 当前迭代次数
        iterate; % 是否还能迭代
    end

    methods

        function self = LogisticSineIterator(x, varargin)
            % LogisticSineIterator - 构造函数
            %
            % Syntax: self = pkg.iterator.LogisticSineIterator(x, 'r', 1, 'u', 0.5, 'k', 18, 'N', 50);
            % @param x double 迭代器初值 (位置参数-必要)
            % @param r double 控制参数 (名称-值对组参数-可选)
            % @param u double 控制参数 (名称-值对组参数-可选)
            % @param k double 控制参数 (名称-值对组参数-可选)
            % @param N uint 初始迭代次数 (名称-值对组参数-可选)
            % @return self 实例化的对象
            % Long description

            p = inputParser; % 函数的输入解析器

            % 必需的由位置确定的位置参数
            p.addRequired('x', @(A) isreal(A));

            % 可选的由名称-值对组确定的参数
            p.addParameter('r', 1, @(A) isreal(A) && A >= 0 && A <= 1);
            p.addParameter('u', 0.5, @(A) isreal(A) && A >= 0 && A <= 1);
            p.addParameter('k', 18, @(A) isreal(A));
            p.addParameter('N', 50, @(A) isreal(A));

            p.parse(x, varargin{:}); % 解析参数

            self.x0 = p.Results.x;
            self.r = p.Results.r;
            self.u = p.Results.u;
            self.k = 2.^p.Results.k;
            self.N0 = p.Results.N;
            self.iterate = true;

            init(self);

        end

        function init(self) % 迭代器初始化
            self.x = self.x0;
            self.N = 0;

            while self.N < self.N0
                [~] = self.getnext;
            end

        end

        function tf = hasnext(self)
            tf = self.iterate;
        end

        function value = getnext(self)
            value = self.x;
            self.x = self.r .* mod(self.u .* sin(pi .* self.x) .* (1 - sin(pi .* self.x)) .* self.k, 1);
            self.N = self.N + 1;
        end

        function mat = getMat(self, varargin)
            mat = zeros(varargin{:});

            for index = 1:numel(mat)
                mat(index) = getnext(self);
            end

        end

    end

end
