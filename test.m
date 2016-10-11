%% reset
clearvars;
addpath(genpath('.'));

%% weight
for weight = linspace(0, 1, 1000)

%% fake peaks
A = [linspace(-4, 10, 200) linspace(9, 1, 100)];
B = [linspace(2, 11, 5) linspace(12, -1, 8)];

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
Aup = A(2:maxAi-1);
Bup = B(2:maxBi-1);
from = 2;
thru = newMaxi-1;
Ascale = length(Aup) / length(from:thru);
Bscale = length(Bup) / length(from:thru);
for n = from:thru
    pos = (n - from) + 1;
    An = cub_int(Aup, pos * Ascale);
    Bn = cub_int(Bup, pos * Bscale);
    newPeak(n) = weighted_mean(An, Bn, weight);
end

%% downward slope
Adn = A(maxAi+1:end-1);
Bdn = B(maxBi+1:end-1);
from = newMaxi + 1;
thru = newL - 1;
Ascale = length(Adn) / length(from:thru);
Bscale = length(Bdn) / length(from:thru);

for n = from:thru
    pos = (n - from) + 1;
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
% pause(0.01)

end