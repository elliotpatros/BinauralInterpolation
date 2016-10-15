function [peak, equal_L] = make_fake_peak(LENGTH, data)
% data args
%
% [xmin1, y; xmax, y; xmin2, y]

upvalue = linspace(data(1,2), data(2,2), length(data(1,1):data(2,1)));
dnvalue = linspace(data(2,2), data(3,2), length(data(2,1):data(3,1)));
peak = [upvalue dnvalue(2:end)];
L = length(peak);

start = data(1,1);
equal_L = zeros(LENGTH,1);
equal_L(start:(start + L) - 1) = peak;


end

