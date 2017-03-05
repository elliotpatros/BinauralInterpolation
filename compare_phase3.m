clearvars;
addpath(genpath('.'));

% plot out how all the phases look together in 3D
% right now, this plot takes a look at the 1st derivative of phase from
% bin0 to nyquist

azims = -25:5:-15;
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

% interpolate derivative
pinter = zeros(size(ptruth));
pinter(1) = weighted_mean(p1(1), p2(1), weight); 
diffs = weighted_mean(diff(p1), diff(p2), weight);
for n = 1:length(diffs)
    pinter(n + 1) = pinter(n) + diffs(n);
end

% interpolate linearly
plinear = weighted_mean(p1, p2, weight);

% plot
nT = 1:length(ptruth);
plot(nT, pinter - plinear)
% plot(nT, ptruth, nT, pinter, nT, plinear);
% legend('truth', 'interpolated', 'linear');
