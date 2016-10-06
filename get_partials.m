function [loudestFreqs, magnitudesByFreq] = get_partials(soundfile, noiseFloor, minPeakDistance)
% GET_PARTIALS finds and sorts loudest partials in a sound file

%% get audio
[x, fs] = audioread(['./AudioSamples/' soundfile]);

%% get fft of input
% fft parameters
rfs = 1/fs;
nyquist = fs / 2;
L = length(x);
nfft = 2^nextpow2(L);

% normalize input
normalizeBy = 1 / max(abs(x));
x = x .* normalizeBy;

% get real fft
X = abs(fft(x, nfft));
X = X ./ max(X);
X = X(1:end/2);
X = gain_to_dB(X);

%% pick peaks
peaks = spectral_peak_picker(X, fs, noiseFloor, minPeakDistance);
loudestFreqs = bin_to_freq(peaks, fs, nfft);
magnitudesByFreq = X(round(peaks));

disp(['peaks in ' soundfile ', sorted by loudness...']);
for n = 1:length(loudestFreqs)
    disp(['frequency ' num2str(loudestFreqs(n)) ' = ' num2str(magnitudesByFreq(n)) ' dB.']);
end

%% plot
faxis = linspace(1, nyquist, nfft / 2)';
plot(faxis, X);
axis([0, nyquist, (noiseFloor - 12), 0]);
hold all;
plot(bin_to_freq(peaks, fs, nfft), X(round(peaks)), 'v');


end

