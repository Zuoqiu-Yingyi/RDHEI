% getYLim.m
function ylim = getYLim(y)
    % getYLim - 获得自定义纵坐标展示范围
    %
    % Syntax: ylim = getYLim(y);
    % @param y 想要展示的向量
    % @return y_min 展示区间下限
    % @return y_max 展示区间上限
    %
    % Long description
    y_min = double(min(y));
    y_max = double(max(y));

    if y_min == 0 && y_max == 0
        y_min = 0;
        y_max = 1;
    elseif y_min >= 0
        y_min = 0;
        y_max = y_max * 1.2;
    elseif y_max <= 0
        y_max = 0;
        y_min = y_min * 1.2;
    else
        y_max = y_max * 1.2;
        y_min = y_min * 1.2;
    end

    ylim = [y_min, y_max];

end
