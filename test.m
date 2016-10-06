%% get audio input
[x, fs] = audioread('./AudioSamples/cello-f2.aiff');

%% get sampling rate info and duration
rfs = 1/fs;
nyquist = fs / 2;

L = length(x);
nfft = 2^nextpow2(L);
seconds = nfft*rfs;

%% do fft
% get real fft of input
X = abs(fft(x, nfft));
% normalize
X = X ./ nfft;
% get frequencies below nyquist
X_nyquist = X(1:end/2);
% plot with x as frequency
faxis = linspace(0, nyquist, nfft / 2)';

%% plot
semilogx(faxis, X_nyquist);
% plot(faxis, X);