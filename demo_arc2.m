clearvars;
addpath(genpath('.'));

[l1,~,fs] = load_binaural(0);
Lhrir = length(l1); clear l1;
dur = 10;
L = fs * dur;

nPositions = L / Lhrir;
azims = -45:5:45;
interp_azims = linspace(-45, 45, nPositions);
lastClosest = zeros(1, 2);

x = randn(L, 1);
y = zeros(L, 2);
for n = 1:nPositions
    % find the two closest positions (az1 and az2) from the desired position (azim)
    azim = interp_azims(n);
    [~, c] = min(abs(azims - azim));
    az1 = azims(c);
    temp = azims(azims~=az1);
    [~, c] = min(abs(temp - azim));
    az2 = temp(c);
    
    % find the weight between the two closest known positions
    closest = sort([az1, az2]);
    weight = (azim - closest(1)) / (closest(2) - closest(1));

    % load filters if they're new
    if (closest ~= lastClosest)
        [l1, r1] = load_binaural(closest(1));
        [l2, r2] = load_binaural(closest(2));
    end

    % morph to get the new hrir's
    new_l = do_morph(l1, l2, weight);
    new_r = do_morph(r1, r2, weight);
    
    % filter this block of input with new filters
    block = ((n - 1) * Lhrir + 1):(n * Lhrir);
    y(block, :) = [filter(new_l, 1, x(block)), filter(new_r, 1, x(block))];
    
    % set up next loop
    lastClosest = closest;
    
    %% update progress
    clc;
    disp([num2str(n*100/nPositions), '%']);
end

soundsc(y, fs);
% clear c temp Lhrir Ly newstuff x_range Ln;