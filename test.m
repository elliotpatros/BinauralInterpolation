clear all;
addpath(genpath('.'));

fs = 50;
dur = 1;
L = dur * fs;
nT = (0:L-1)'./fs;

x1 = sin((2*pi*5).*nT) .* hanning(L);
x2 = cos((2*pi*7).*nT) .* hanning(L);

y1 = filter(x2, 1, x1);
y2 = time_domain_FIR(x1, x2);

plot(y1 - y2);
% plot(y1); hold on;
% plot(y2); hold off;