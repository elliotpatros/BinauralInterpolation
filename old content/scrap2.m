%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
azim1 = 0;
elev1 = 0;
azim2 = 5;
elev2 = 0;

dur = 1;
gain = 0.1;
nIterations = 10;

%% load audio
% get HRIR's
[l1, r1, fs] = load_binaural(azim1, elev1);
[l2, r2] = load_binaural(azim2, elev2);
Lhrir = length(l1);

% make input and output signal
L = dur * fs;
blockSize = L + Lhrir - 1;
x = make_noise(L, 1);
y = zeros(blockSize * nIterations, 2);

%% morph
weights = linspace(0, 1, nIterations);
for n = 1:nIterations
    weight = weights(n);
    new_l = do_morph(l1, l2, weight, fs);
    new_r = do_morph(r1, r2, weight, fs);
    
    block = (blockSize * (n - 1) + 1):(blockSize * n);
    y(block, :) = [conv(x, new_l), conv(x, new_r)];
end;

plot(y)
y = y ./ max(abs(y));
sound(y.*gain, fs);