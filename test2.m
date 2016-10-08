clearvars;
addpath(genpath('.'));

%% get user input
azim1 = 5;
elev1 = 0;
azim2 = 15;
elev2 = 0;

%% get audio
[lx1, ~, fs] = load_binaural(azim1, elev1);
lx2 = load_binaural(azim2, elev2);

%% pick peaks
[lY1, lBins1] = pick_peaks(lx1, fs);
[lY2, lBins2] = pick_peaks(lx2, fs);

%% plot
subplot(211);
plot_peaks(lY1, lBins1, fs);
subplot(212);
plot_peaks(lY2, lBins2, fs);