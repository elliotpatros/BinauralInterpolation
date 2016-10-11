%% reset
clearvars;
addpath(genpath('.'));

%% weight
weight = 0.5;

%% peaks
A = [0 1 2 3 4 5 4 3 2 1 0];
B = [0 2 3 1 0];

%% weights
Aweight = 1 - weight;
Bweight = weight;

%% lengths
LA = length(A);
LB = length(B);
newL = round(Aweight * LA + Bweight * LB);
newPeak = zeros(newL, 1);

%% maxima
[maxA, maxAi] = max(A);
[maxB, maxBi] = max(B);
newMax = Aweight * maxA + Bweight * maxB;
newMaxi = round(Aweight * maxAi + Aweight * maxBi);

%% interpolate min and max
newPeak(1) = weighted_mean(A(1), B(1), weight);
newPeak(newL) = weighted_mean(A(end), B(end), weight);
newPeak(newMaxi) = weighted_mean(A(maxAi), B(maxBi), weight);

%% upward slope
Aup = A(1:maxAi);
Bup = B(1:maxBi);
from = 2;
thru = newMaxi-1;
Ascale = (length(Aup) - 1) / length(from:thru);
Bscale = (length(Bup) - 1) / length(from:thru);
for n = from:thru
    pos = (n + 1) - from;
    An = cub_int(Aup, pos * Ascale);
    Bn = cub_int(Bup, pos * Bscale);
    newPeak(n) = weighted_mean(An, Bn, weight);
end

%% downward slope
Adn = A(maxAi:end);
Bdn = B(maxBi:end);
from = newMaxi + 1;
thru = newL - 1;
Ascale = (length(Adn) - 1) / length(from:thru);
Bscale = (length(Bdn) - 1) / length(from:thru);

for n = from:thru
    pos = (n + 1) - from;
    An = cub_int(Adn, pos * Ascale);
    Bn = cub_int(Bdn, pos * Bscale);
    newPeak(n) = weighted_mean(An, Bn, weight);
end

%% plot
maxL = max(LA, LB);

toplot = zeros(3, maxL);
toplot(1, 1:LA) = A;
toplot(2, 1:LB) = B;
toplot(3, 1:newL) = newPeak;
plot(toplot')

% subplot(311); plot(A);
% subplot(312); plot(B);
% subplot(313); plot(newPeak);