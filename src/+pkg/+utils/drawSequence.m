% drawSequence.m
function drawSequence(x, y, varargin)
    % drawSequence - 绘制序列
    %
    % Syntax: drawSequence(x, y, 'k-o', 'LineWidth', 0.5, 'MarkerSize', 6, 'padL', 0, 'padR', 0, 'ylim', [-inf, inf], 'title', '', 'xlabel', '', 'ylabel', '', 'legend', 'off', 'box', 'on', 'grid', 'on');
    % @param x 序列的横坐标值 (位置参数-必要)
    % @param y 序列的纵坐标值 (位置参数-必要)
    % @param style 图形样式 (位置参数-可选)
    % @param LineWidth 线条宽度 (名称-值对组参数-可选)
    % @param MarkerSize 标记大小 (名称-值对组参数-可选)
    % @param padL 坐标轴左侧填充 (名称-值对组参数-可选)
    % @param padR 坐标轴右侧填充 (名称-值对组参数-可选)
    % @param ylim y轴坐标范围 (名称-值对组参数-可选)
    % @param title 图形标题 (名称-值对组参数-可选)
    % @param xlabel x轴标签 (名称-值对组参数-可选)
    % @param ylabel y轴标签 (名称-值对组参数-可选)
    % @param legend 图例内容 (名称-值对组参数-可选)
    % @param box 显示图表边框 (名称-值对组参数-可选)
    % @param grid 显示网格线 (名称-值对组参数-可选)
    % Long description

    %{
    % # 图形样式
    % # 颜色: b蓝 g绿 r红 y黄 c青 m紫 k黑 w白
    % # 线条: -实线 :点线 --虚线 -.点划线
    % # 标记: o圆圈 +十字 *星号 .实点 x叉号 _水平线条 |垂直线条 s方形 d菱形 v下三角 ^上三角 <左三角 >右三角 p五角星 h六角形
    %}

    p = inputParser; % 函数的输入解析器

    % 必需的由位置确定的位置参数
    p.addRequired('x');
    p.addRequired('y');

    % 可选的由位置确定的参数
    p.addOptional('style', 'k-o', @(A) ischar(A));

    % 可选的由名称-值对组确定的参数
    p.addParameter('LineWidth', 0.5, @(A) isreal(A));
    p.addParameter('MarkerSize', 6, @(A) isreal(A));
    p.addParameter('padL', 0, @(A) isreal(A));
    p.addParameter('padR', 0, @(A) isreal(A));
    p.addParameter('ylim', [-inf, inf], @(A) isreal(A) && A(1) <= A(2));
    p.addParameter('title', '', @(A) ischar(A));
    p.addParameter('xlabel', '', @(A) ischar(A));
    p.addParameter('ylabel', '', @(A) ischar(A));
    p.addParameter('legend', 'off', @(A) ischar(A));
    p.addParameter('box', 'on', @(A) ischar(A));
    p.addParameter('grid', 'on', @(A) ischar(A));

    p.parse(x, y, varargin{:}); % 解析参数

    stem(p.Results.x, p.Results.y, p.Results.style, 'LineWidth', p.Results.LineWidth, 'MarkerSize', p.Results.MarkerSize); % 横坐标 纵坐标 图形
    xlim([...
            p.Results.x(1) - p.Results.padL * (p.Results.x(2) - p.Results.x(1)), ...
            p.Results.x(end) + p.Results.padR * (p.Results.x(end) - p.Results.x(end - 1))]); % 横坐标范围
    ylim(p.Results.ylim); % 纵坐标范围

    title(p.Results.title); % 图形标题
    xlabel(p.Results.xlabel); % 横坐标轴标题
    ylabel(p.Results.ylabel); % 纵坐标轴标题
    legend({p.Results.legend}, 'Interpreter', 'latex', 'Location', 'bestoutside', 'FontSize', 14) % 图例内容

    box(p.Results.box); % 显示图表边框
    grid(p.Results.grid); % 显示网格线
end
