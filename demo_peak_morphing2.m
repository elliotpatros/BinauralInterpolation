%% reset
clearvars;
addpath(genpath('.'));

%% weight
% weight = 0.5;
for weight = linspace(0, 1, 100)

%% make fake peaks
LENGTH = 50;

Astart = 2;
ALX = 1; ALY = -1;
AMX = 25; AMY = 30;
ARX = 40; ARY = -5;

Bstart = 3;
BLX = 1; BLY = -20;
BMX = 10; BMY = 50;
BRX = 20; BRY = 14;

[A, Aplot] = make_fake_peak(LENGTH, [ALX + Astart, ALY; ...
                                     AMX + Astart, AMY; ...
                                     ARX + Astart, ARY]);
[B, Bplot] = make_fake_peak(LENGTH, [BLX + Bstart, BLY; ...
                                     BMX + Bstart, BMY; ...
                                     BRX + Bstart, BRY]);

%% find new y's
newLY = round(weighted_mean(ALY, BLY, weight));
newMY = round(weighted_mean(AMY, BMY, weight));
newRY = round(weighted_mean(ARY, BRY, weight));

%% find new x's
newLX = round(weighted_mean(ALX, BLX, weight));
newMX = round(weighted_mean(AMX, BMX, weight));
newRX = round(weighted_mean(ARX, BRX, weight));
newStart = round(weighted_mean(Astart, Bstart, weight));
newL = newRX;
newPeak = zeros(newL, 1);

%% make new mins and max
newPeak(1) = weighted_mean(A(1), B(1), weight);
newPeak(end) = weighted_mean(A(end), B(end), weight);
newPeak(newMX) = weighted_mean(A(AMX), B(BMX), weight);

%% make new upward slope
Aup = A(1:AMX);
Bup = B(1:BMX);
newUpRange = 2:newMX - 1;
Ascale = (length(Aup) - 2) / length(newUpRange);
Bscale = (length(Bup) - 2) / length(newUpRange);

for n = newUpRange
    pos = n;
    An = cub_int(Aup, pos * Ascale);
    Bn = cub_int(Bup, pos * Bscale);
    newPeak(n) = weighted_mean(An, Bn, weight);
end

%% make new downward slope
Adn = A(AMX:end);
Bdn = B(BMX:end);
newDnRange = newMX + 1:newL - 1;

Ascale = (length(Adn) - 2) / length(newDnRange);
Bscale = (length(Bdn) - 2) / length(newDnRange);

for n = newDnRange
    pos = (n - newDnRange(1)) + 2;
    An = cub_int(Adn, pos * Ascale);
    Bn = cub_int(Bdn, pos * Bscale);
    newPeak(n) = weighted_mean(An, Bn, weight);
end

%% put new peak in zeros with the rest of them
newPeakPlot = zeros(LENGTH, 1);
newPeakPlot(newStart + 1:newL + newStart) = newPeak;
plot([Aplot Bplot newPeakPlot]);
drawnow;

%% plot

% subplot(311); plot(A);
% subplot(312); plot(B);
% subplot(313); plot(newPeak);
% axis([min(ALX, BLX), max(ARX, BRX), min([A; B]), max([A; B])]);
% drawnow;

end

%% lengths
% LA = length(A);
% LB = length(B);
% newL = round(weighted_mean(LA, LB, weight));
% newPeak = zeros(newL, 1);
% 
% %% maxima
% [maxA, maxAi] = max(A);
% [maxB, maxBi] = max(B);
% newMax = weighted_mean(maxA, maxB, weight);
% newMaxi = round(weighted_mean(maxAi, maxBi, weight));
% 
% %% interpolate min and max
% newPeak(1) = weighted_mean(A(1), B(1), weight);
% newPeak(newL) = weighted_mean(A(end), B(end), weight);
% newPeak(newMaxi) = weighted_mean(A(maxAi), B(maxBi), weight);
% 
% %% upward slope
% Aup = A(1:maxAi);
% Bup = B(1:maxBi);
% from = 2;
% thru = newMaxi-1;
% Ascale = (length(Aup) - 2) / length(from:thru);
% Bscale = (length(Bup) - 2) / length(from:thru);
% for n = from:thru
%     pos = (n - from) + 2;
%     An = cub_int(Aup, pos * Ascale);
%     Bn = cub_int(Bup, pos * Bscale);
%     newPeak(n) = weighted_mean(An, Bn, weight);
% end
% 
% %% downward slope
% Adn = A(maxAi:end);
% Bdn = B(maxBi:end);
% from = newMaxi + 1;
% thru = newL - 1;
% Ascale = (length(Adn) - 2) / length(from:thru);
% Bscale = (length(Bdn) - 2) / length(from:thru);
% 
% for n = from:thru
%     pos = (n - from) + 2;
%     An = cub_int(Adn, pos * Ascale);
%     Bn = cub_int(Bdn, pos * Bscale);
%     newPeak(n) = weighted_mean(An, Bn, weight);
% end
% 
% %% plot
% maxL = max(LA, LB);
% 
% toplot = zeros(3, maxL);
% toplot(1, 1:LA) = A;
% toplot(2, 1:LB) = B;
% toplot(3, 1:newL) = newPeak;
% plot(toplot')
% 
% drawnow;
