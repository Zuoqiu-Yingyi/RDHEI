% Mac.m
% # [Mac (Java SE 16 & JDK 16)](https://docs.oracle.com/en/java/javase/16/docs/api/java.base/javax/crypto/Mac.html)
classdef Mac < handle

    properties % 公有属性
    end

    properties (SetAccess = protected) % 写受保护属性
        algorithm = []; % 算法名称
        key = []; % javax.crypto.spec.SecretKeySpec 密钥实例
        instance = []; % javax.crypto.Mac.getInstance 返回的实例
        output = []; % Mac 函数输出结果
        length = []; % Mac 函数输出长度
    end

    properties (Dependent = true) % 调用时实时计算的属性

    end

    methods (Static = true) % 静态方法

    end

    methods % 公开方法

        % 构造函数
        function self = Mac(algorithm, passphrase, varargin)
            % Mac - 构造函数
            %
            % Syntax: self = Mac(spectrum, SC, GI, branch, varargin);
            % @param algorithm(str) 算法名称 (位置参数-必要)
            % @param passphrase(str) 口令 (位置参数-必要)
            % @return self 实例化的对象
            % Long description

            p = inputParser; % 函数的输入解析器

            % 必需的由位置确定的位置参数
            % 参考: [Java Security Standard Algorithm Names](https://docs.oracle.com/en/java/javase/16/docs/specs/security/standard-names.html#mac-algorithms)
            p.addRequired('algorithm', @(A) ischar(A) && any(validatestring(A, {...
                                                                    'HmacMD5', ...
                                                                    'HmacSHA1', ...
                                                                    'HmacSHA224', ...
                                                                    'HmacSHA256', ...
                                                                    'HmacSHA384', ...
                                                                    'HmacSHA512' ...
                                                                    % 'HmacSHA512/224', ...
                                                                    % 'HmacSHA512/256', ...
                                                                    % 'HmacSHA3-224', ...
                                                                    % 'HmacSHA3-256', ...
                                                                    % 'HmacSHA3-384', ...
                                                                    % 'HmacSHA3-512', ...
                                                                    % 'HmacPBESHA1', ...
                                                                    % 'HmacPBESHA224', ...
                                                                    % 'HmacPBESHA256', ...
                                                                    % 'HmacPBESHA384', ...
                                                                    % 'HmacPBESHA512', ...
                                                                    % 'HmacPBESHA512/224', ...
                                                                    % 'HmacPBESHA512/256', ...
                                                                    })));
            p.addRequired('passphrase', @(A) ischar(A));

            p.parse(algorithm, passphrase, varargin{:}); % 解析参数

            self.algorithm = p.Results.algorithm;
            self.instance = javax.crypto.Mac.getInstance(p.Results.algorithm);

            init(self, p.Results.passphrase);

            self.length = self.instance.getMacLength();

        end

        % 密钥设置
        function setKey(self, key)
            % @param key 密钥/口令 (位置参数-必要)
            p = inputParser; % 函数的输入解析器

            % 必需的由位置确定的位置参数
            p.addRequired('key', @(A) ischar(A) || isa(A, 'uint8') || isa(A, 'java.security.Key'));

            p.parse(key); % 解析参数

            if ischar(p.Results.key)
                self.key = javax.crypto.spec.SecretKeySpec(unicode2native(p.Results.key), self.algorithm);
            elseif isa(p.Results.key, 'uint8')
                self.key = javax.crypto.spec.SecretKeySpec(p.Results.key, self.algorithm);
            elseif isa(p.Results.key, 'java.security.Key')
                self.key = p.Results.key;
            end

        end

        % 使用密钥初始化
        function init(self, varargin)
            % @param key 密钥/口令 (位置参数-可选)
            p = inputParser; % 函数的输入解析器

            % 可选的由位置确定的参数
            p.addOptional('key', self.key, @(A) ischar(A) || isa(A, 'uint8') || isa(A, 'java.security.Key'));

            p.parse(varargin{:}); % 解析参数

            setKey(self, p.Results.key);
            self.instance.init(self.key, varargin{2:end});

        end

        % 更新消息的输入
        function update(self, messageInput, varargin)
            % @param messageInput 消息输入 (位置参数-必要)
            p = inputParser; % 函数的输入解析器

            % 必需的由位置确定的位置参数
            p.addRequired('messageInput', @(A) ischar(A) || isa(A, 'uint8'));

            p.parse(messageInput, varargin{:}); % 解析参数

            if ischar(p.Results.messageInput)
                self.instance.update(unicode2native(p.Results.messageInput), varargin{:});
            elseif isa(p.Results.messageInput, 'uint8')
                self.instance.update(p.Results.messageInput, varargin{:});
            else
            end

            self.output = self.instance.doFinal();
        end

        % 获得散列值
        function [outputByte, outputStr] = doFinal(self, varargin)

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

    end

    methods (Abstract = true) % 抽象方法

    end

end
