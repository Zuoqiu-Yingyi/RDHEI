% LogisticImprovedIterator.m
classdef LogisticImprovedIterator < pkg.iterator.Iterator
    % 改进 Ligistic 混沌变量序列生成迭代器类
    properties
        % 属性
        x; % 当前迭代值
        k; % 控制参量
        N; % 当前迭代次数
        iterate; % 是否还能迭代
    end

    methods

        function self = LogisticImprovedIterator(varargin)
            % LogisticImprovedIterator - 构造函数
            %
            % Syntax: self = LogisticImprovedIterator('seed', 0.5, 'k', 10001.57, 'N', 50);
            % @param seed double 随机种子 (名称-值对组参数-可选)
            % @param k double 参数 (名称-值对组参数-可选)
            % @param N uint 初始迭代次数 (名称-值对组参数-可选)
            % @return self 实例化的对象
            % Long description

            p = inputParser; % 函数的输入解析器

            % 可选的由名称-值对组确定的参数
            p.addParameter('seed', 0.5, @(A) isreal(A));
            p.addParameter('k', 10001.57, @(A) isreal(A));
            p.addParameter('N', 50, @(A) isreal(A));

            p.parse(varargin{:}); % 解析参数

            self.x = p.Results.seed;
            self.k = p.Results.k;
            self.N = 0;
            self.iterate = true;

            while self.N < p.Results.N
                [~] = self.getnext;
            end
        end

        function tf = hasnext(self)
            tf = self.iterate;
        end

        function value = getnext(self)
            self.x = self.k * self.x * (1 - self.x);
            self.x = self.x - floor(self.x);
            self.N = self.N + 1;
            value = self.x;
        end

    end

end
