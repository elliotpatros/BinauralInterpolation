clearvars;
addpath(genpath('.'));

%% get user input
soundfile = '400Hz.wav';
noiseFloor = -Inf;
minPeakWidth = 4000;

%% get audio
[x, fs] = audioread(soundfile);

%% do test
[Y, nfft] = do_fft(x, true);
peakBins = get_peak_bins(Y, noiseFloor);
peakBins = sort_loudest_peaks(Y, peakBins);
peakBins = filter_peaks_by_width(Y, peakBins, minPeakWidth, fs, nfft);

%% organize results
peakFreqs = bin_to_freq(peakBins, fs, nfft);
magnitudes = Y(round(peakBins));

%% plot
nBins = length(Y);
faxis = linspace(0, bin_to_freq(nBins, fs, nfft), nBins)';
plot(faxis, Y);
hold on;
plot(peakFreqs, Y(peakBins), 'v');
hold off;