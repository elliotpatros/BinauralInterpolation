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

% interpolate linearly
M = find_morphing_surface(x1, x2);
xlin = do_morph_with_surface(x1, x2, M, weight);

% interpolate ITD
weight = (itd(azims(2)) - itd(azims(1))) ./ (itd(azims(3)) - itd(azims(1)));
if isinf(weight)
    weight = 0.5;
end

xitd = do_morph_with_surface(x1, x2, M, weight);

itd_error(n) = rms(xtruth - xitd);
lin_error(n) = rms(xtruth - xlin);

plot(A, [lin_error; itd_error])
end
