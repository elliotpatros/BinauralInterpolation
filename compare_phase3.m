clearvars;
addpath(genpath('.'));

% plot out how all the phases look together in 3D
% right now, this plot takes a look at the 1st derivative of phase from
% bin0 to nyquist

azims = -35:5:-25;
x = load_binaural(0);

nAzims = length(azims);
L = length(x);
weight = 0.5;
clear x;

x1 = load_binaural(azims(1));
x2 = load_binaural(azims(3));
xtruth = load_binaural(azims(2));

p1 = unwrap(angle(fft(x1)));
p2 = unwrap(angle(fft(x2)));
ptruth = unwrap(angle(fft(xtruth)));
p1 = p1(1:end/2 + 1);
p2 = p2(1:end/2 + 1);
ptruth = ptruth(1:end/2 + 1);

% interpolate linearly
plinear = weighted_mean(p1, p2, weight);

% interpolate ITD
weight = (itd(azims(2)) - itd(azims(1))) ./ (itd(azims(3)) - itd(azims(1)));
pitd = weighted_mean(p1, p2, weight);

% plot
nT = 1:length(ptruth);
plot(nT, [pitd - ptruth, plinear - ptruth])
% plot(nT, ptruth, nT, pinter, nT, plinear);
% legend('truth', 'interpolated', 'linear');
