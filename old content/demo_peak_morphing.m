%% reset
clearvars;
addpath(genpath('.'));

%% weight
for weight = linspace(1, 0, 1000)

%% fake peaks
A = [linspace(-4, 10, 200) linspace(9, 1, 100)];
B = [linspace(2, 11, 50) linspace(12, -1, 80)];

%% lengths
LA = length(A);
LB = length(B);
newL = round(weighted_mean(LA, LB, weight));
newPeak = zeros(newL, 1);

%% maxima
[maxA, maxAi] = max(A);
[maxB, maxBi] = max(B);
newMax = weighted_mean(maxA, maxB, weight);
newMaxi = round(weighted_mean(maxAi, maxBi, weight));

%% interpolate min and max
newPeak(1) = weighted_mean(A(1), B(1), weight);
newPeak(newL) = weighted_mean(A(end), B(end), weight);
newPeak(newMaxi) = weighted_mean(A(maxAi), B(maxBi), weight);

%% upward slope
Aup = A(1:maxAi);
Bup = B(1:maxBi);
from = 2;
thru = newMaxi-1;
Ascale = (length(Aup) - 2) / length(from:thru);
Bscale = (length(Bup) - 2) / length(from:thru);
for n = from:thru
    pos = (n - from) + 2;
    An = cub_int(Aup, pos * Ascale);
    Bn = cub_int(Bup, pos * Bscale);
    newPeak(n) = weighted_mean(An, Bn, weight);
end

%% downward slope
Adn = A(maxAi:end);
Bdn = B(maxBi:end);
from = newMaxi + 1;
thru = newL - 1;
Ascale = (length(Adn) - 2) / length(from:thru);
Bscale = (length(Bdn) - 2) / length(from:thru);

for n = from:thru
    pos = (n - from) + 2;
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

drawnow;

end