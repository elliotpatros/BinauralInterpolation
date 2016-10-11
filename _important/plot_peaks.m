function plot_peaks(Y, bins, fs)
%PLOT_PEAKS plots peaks

nBins = length(Y);
nfft = nBins * 2;
freqs = bin_to_freq(bins, fs, nfft);
faxis = linspace(0, bin_to_freq(nBins, fs, nfft), nBins)';
plot(faxis, Y);
hold on;
plot(freqs, Y(bins), 'v');
hold off;

end

