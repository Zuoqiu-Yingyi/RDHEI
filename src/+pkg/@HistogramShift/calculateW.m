function [Whl, Whr, Wvu, Wul] = calculateW(self, s, t, Hl, Hr, Vu, Vl, varargin)
    % 计算预测权值 w_Hl, w_Hr, w_Vu, w_Vl
    D = Hl .* (1 - s) + Hr .* s + Vu .* (1 - t) + Vl .* t;
    Whl = Hl .* (1 - s) ./ D;
    Whr = Hr .* s ./ D;
    Wvu = Vu .* (1 - t) ./ D;
    Wul = Vl .* t ./ D;
end
