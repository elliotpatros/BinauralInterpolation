clearvars;
addpath(genpath('.'));

nPositions = 100;
azims = -45:5:45;
interp_azims = linspace(-45, 45, nPositions);

L = 441000;
x = randn(L, 1);
y = [];
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
    
    % morph to get the new hrir's
    [l1, r1, fs] = load_binaural(closest(1));
    [l2, r2] = load_binaural(closest(2));
    Lhrir = length(l1);
    
    new_l = do_morph(l1, l2, weight);
    new_r = do_morph(r1, r2, weight);
    
    wlen = Lhrir * 20;
    x_range = ((n - 1) * wlen + 1):(n * wlen);
    x_range = mod(x_range, L);

    newstuff = [conv(x(x_range), new_l) conv(x(x_range), new_r)];
    Ln = length(newstuff);
    newstart = floor(max(x_range(1) - Ln/2, 1));
    newend = newstart + Ln - 1;
    y = [y; zeros(newend - length(y), 2)];
    y(newstart:newend, :) = y(newstart:newend, :) + newstuff;
end

soundsc(y, fs);
clear c temp Lhrir Ly newstuff x_range Ln;