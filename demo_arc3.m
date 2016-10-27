clearvars;
addpath(genpath('.'));

[l1,~,fs] = load_binaural(0);
Lhrir = length(l1); clear l1;

x = audioread('electric_razor.wav');
L = length(x);
y = zeros(L, 2);

nPositions = L / Lhrir;
azims = -45:5:45;
interp_azims = linspace(-45, 45, nPositions);
lastClosest = zeros(1, 2);
filter_state = zeros(Lhrir-1,2);
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
    
    [lx, filter_state(:,1)] = filter(new_l, 1, x(block), filter_state(:,1));
    [rx, filter_state(:,2)] = filter(new_r, 1, x(block), filter_state(:,2));
    y(block, :) = [lx, rx];
    
    % set up next loop
    lastClosest = closest;
    
    %% update progress
    clc;
    disp([num2str(round(n*100/nPositions, 1)), '%']);
end

soundsc(y, fs);
% clear block c filter_state interp_azims lastClosest n temp;