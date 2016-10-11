%% reset
clearvars;
addpath(genpath('.'));

%% compute new length, local max index
weight = 0.5;

% peaks
A = [0 1 2 3 4 5 4 3 2 1 0];
B = [0 2 5 3 1 0];

% weights
Aweight = 1 - weight;
Bweight = weight;

% lengths
LA = length(A);
LB = length(B);
newL = round(Aweight * LA + Bweight * LB);

% maxima
[maxA, maxAi] = max(A);
[maxB, maxBi] = max(B);
newMax = Aweight * maxA + Bweight * maxB;
newMaxi = round(Aweight * maxAi + Aweight * maxBi);


