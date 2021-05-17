function varargout = copy(self, varargin)
    % copy - 从原对象生成新对象
    %
    % Syntax: varargout = copy(self, 'sequence', self.sequence, 'spectrum', self.spectrum, 'T0', self.time_begin, 'T1', self.time_end, 'Fs', self.frequency_sample, 'Rs', self.rate_symbol_rate, 'stuffing', self.symbol_stuffing, 'packet', self.symbol_packet);
    % @param sequence 传输的序列 (名称-值对组参数-可选)
    % @param spectrum 传输的波形 (名称-值对组参数-可选)
    % @param T0 信号开始时间(单位: s) (名称-值对组参数-可选)
    % @param T1 信号结束时间(单位: s) (名称-值对组参数-可选)
    % @param Fs 信号采样频率(单位: Hz) (名称-值对组参数-可选)
    % @param Rs 码元传输速率(单位: symbol/s) (名称-值对组参数-可选)
    % @param stuffing 位填充数量(单位: symbol) (名称-值对组参数-可选)
    % @param packet 码元分组长度(单位: symbol) (名称-值对组参数-可选)
    % @return varargout 多个实例化的对象(元胞数组)
    % Long description

    p = inputParser; % 函数的输入解析器

    % 可选的由名称-值对组确定的参数
    p.addParameter('sequence', self.sequence, @(A) isnumeric(A) || islogical(A));
    p.addParameter('spectrum', self.spectrum, @(A) isnumeric(A) || islogical(A));
    p.addParameter('T0', self.time_begin, @(A) isreal(A));
    p.addParameter('T1', self.time_end, @(A) isreal(A));
    p.addParameter('Fs', self.frequency_sample, @(A) isreal(A));
    p.addParameter('Rs', self.symbol_rate, @(A) isreal(A));
    p.addParameter('stuffing', self.symbol_stuffing, @(A) isreal(A));
    p.addParameter('packet', self.symbol_packet, @(A) isreal(A));

    p.parse(varargin{:}); % 解析参数

    varargout = cell(1, nargout); % 创建待返回的元胞数组 % 构造函数

    for index = 1:nargout
        varargout{index} = pkg.Signal(...
            p.Results.sequence, ...
            p.Results.spectrum, ...
            'T0', p.Results.T0, ...
            'T1', p.Results.T1, ...
            'Fs', p.Results.Fs, ...
            'Rs', p.Results.Rs, ...
            'stuffing', p.Results.stuffing, ...
            'packet', p.Results.packet);
    end

end
