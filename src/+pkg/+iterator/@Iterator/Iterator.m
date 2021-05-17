classdef Iterator < handle
    %

    % Copyright 2016-2020 The MathWorks, Inc.

    methods (Abstract)
        tf = hasnext(obj);
        value = getnext(obj); % throws mlspark:iterator:StopIteration
    end

end
