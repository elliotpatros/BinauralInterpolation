clearvars;
addpath(genpath('.'));

% find out whether itd or linear interpolation is better for phase by
% checking the RMS of the error of both for the entire set.

A = -40:5:40;
itd_error = zeros(1, length(A));
lin_error = zeros(1, length(A));

for n = 1:length(A)
azims = [A(n)-5, A(n), A(n)+5];
x1 = load_binaural(azims(1));

L = length(x1);
weight = 0.5;

x2 = load_binaural(azims(3));
xtruth = load_binaural(azims(2));

p1 = unwrap(angle(fft(x1)));
p2 = unwrap(angle(fft(x2)));
ptruth = unwrap(angle(fft(xtruth)));
p1 = p1(1:end/2 + 1);
p2 = p2(1:end/2 + 1);
ptruth = ptruth(1:end/2 + 1);

% interpolate linearly
plin = weighted_mean(p1, p2, weight);

% interpolate ITD
weight = (itd(azims(2)) - itd(azims(1))) ./ (itd(azims(3)) - itd(azims(1)));
if isinf(weight)
    weight = 0.5;
end

pitd = weighted_mean(p1, p2, weight);

itd_error(n) = rms(ptruth - pitd);
lin_error(n) = rms(ptruth - plin);
end
