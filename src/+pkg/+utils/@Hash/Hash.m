% Hash.m
% # [MessageDigest (Java SE 16 & JDK 16)](https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/security/MessageDigest.html#reset())
classdef Hash < handle

    properties % 公有属性
    end

    properties (SetAccess = protected) % 写受保护属性
        algorithm = []; % 算法名称
        instance = []; % java.security.MessageDigest.getInstance 返回的实例
        output = []; % hash函数输出结果
        length = []; % hash 函数输出长度
    end

    properties (Dependent = true) % 调用时实时计算的属性

    end

    methods (Static = true) % 静态方法

    end

    methods % 公开方法

        % 构造函数
        function self = Hash(algorithm, varargin)
            % Hash - 构造函数
            %
            % Syntax: self = Hash(spectrum, SC, GI, branch, varargin);
            % @param algorithm(str) 算法名称 (位置参数-必要)
            % @return self 实例化的对象
            % Long description

            p = inputParser; % 函数的输入解析器

            % 必需的由位置确定的位置参数
            % 参考: [Java Security Standard Algorithm Names](https://docs.oracle.com/en/java/javase/16/docs/specs/security/standard-names.html#mac-algorithms)
            p.addRequired('algorithm', @(A) ischar(A) && any(validatestring(A, {...
                                                                    'MD2', ...
                                                                    'MD5', ...
                                                                    'SHA-1', ...
                                                                    'SHA-224', ...
                                                                    'SHA-256', ...
                                                                    'SHA-384', ...
                                                                    'SHA-512' ...
                                                                    % 'SHA-512/224', ...
                                                                    % 'SHA-512/256', ...
                                                                    % 'SHA3-224', ...
                                                                    % 'SHA3-256', ...
                                                                    % 'SHA3-384', ...
                                                                    % 'SHA3-512', ...
                                                                    })));

            p.parse(algorithm, varargin{:}); % 解析参数

            self.algorithm = p.Results.algorithm;
            self.instance = java.security.MessageDigest.getInstance(p.Results.algorithm);

            self.length = self.instance.getDigestLength();

        end

        % 更新散列的输入
        function update(self, hashInput, varargin)
            % @param hashInput 散列输入 (位置参数-必要)
            p = inputParser; % 函数的输入解析器

            % 必需的由位置确定的位置参数
            p.addRequired('hashInput', @(A) ischar(A) || isa(A, 'uint8'));

            p.parse(hashInput, varargin{:}); % 解析参数

            if ischar(p.Results.hashInput)
                self.instance.update(unicode2native(p.Results.hashInput));
            elseif isa(p.Results.hashInput, 'uint8')
                self.instance.update(p.Results.hashInput);
            else
            end

            self.output = self.instance.digest();
        end

        % 获得散列值
        function [outputByte, outputStr] = digest(self, varargin)

            switch nargin
                case 1
                    outputByte = typecast(self.output, 'uint8');
                    outputStr = sprintf('%02X', outputByte);
                otherwise
                    outputByte = zeros(self.length, nargin - 1, 'uint8');
                    outputStr = strings(1, nargin - 1);

                    for index = 1:(nargin - 1)
                        update(self, varargin{index});
                        outputByte(:, index) = typecast(self.output, 'uint8');
                        outputStr(index) = sprintf('%02X', outputByte(:, index));
                    end

            end

        end

        % 重置
        function reset(self, varargin)
            self.instance.reset();
        end

    end

    methods (Abstract = true) % 抽象方法

    end

end
