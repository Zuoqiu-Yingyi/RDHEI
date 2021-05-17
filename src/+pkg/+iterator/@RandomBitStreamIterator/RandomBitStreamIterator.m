% LogisticImprovedIterator.m
classdef RandomBitStreamIterator < pkg.iterator.Iterator
    % 改进 Ligistic 随机比特流迭代器
    properties
        % 属性
        x = 0; % 当前迭代值
        N = 0; % 当前迭代次数
        iterate; % 是否还能迭代
    end

    methods

        function self = RandomBitStreamIterator(varargin)
            % RandomBitStreamIterator - 构造函数
            %
            % Syntax: self = RandomBitStreamIterator('seed', 0, 'N', 0);
            % @param seed double 随机种子 (名称-值对组参数-可选)
            % @param N uint 初始迭代次数 (名称-值对组参数-可选)
            % @return self 实例化的对象
            % Long description

            p = inputParser; % 函数的输入解析器

            % 可选的由名称-值对组确定的参数
            p.addParameter('seed', 0, @(A) isreal(A));
            p.addParameter('N', 0, @(A) isreal(A));

            p.parse(varargin{:}); % 解析参数

            rng(p.Results.seed);
            self.N = 0;
            self.iterate = true;

            while self.N < p.Results.N
                [~] = self.getnext;
            end

            self.x = randi(2);
        end

        function tf = hasnext(self)
            tf = self.iterate;
        end

        function value = getnext(self)
            value = (self.x == 1);
            self.x = randi(2);
            self.N = self.N + 1;
        end

        function value = previewnext(self)
            value = (self.x == 1);
        end

    end

end
