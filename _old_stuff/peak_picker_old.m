%% reset
clear all;
clc;
clf;

%% user parameters
soundfile = 'air sounds/Bb3_straight.wav'; 
maxNumPeaks = 24;                           % max number of peaks you want
noiseFloor = -42;                           % the quietest peak you want (dB.)
minPeakDistance = 40;                       % how wide do you think peaks are (Hz.)?
normalizeResults = true;                    % should results be noramlized? (true or false)

%% get input and stuff
[x, fs] = audioread(['./AudioSamples/' soundfile]);
x = sum(x, 2);                              % mix to mono
L = length(x);                              % duration of soundfile (samples)
rfs = 1/fs;                                 % duration of a sample (seconds)
nyquist = fs / 2;                           % nyquist frequency (Hz)
nfft = 2^nextpow2(L);                       % duration of fft input (samples)

%% do fft
x = x .* hanning(L);                        % scale input by hanning window
X = abs(fft(x, nfft));                      % get real-fft of soundfile
X = X(1:end/2);                             % get frequencies below nyquist
X = X ./ max(X);                            % normalize fft
X = gain_to_dB(X);                          % convert magnitude to dB.

%% pick peaks
% sort frequency bins from loudest to quietest
[~, bins] = sort(X, 'descend');             

% remove bins that are too quiet
bins = bins(X(bins) >= noiseFloor);         

% remove bins that are within minPeakDistance of louder peaks
binWidth = freq_to_bin(minPeakDistance, fs, nfft);
n = 1;
while n <= length(bins)
    loudest = bins(n);                      % get the nth loudest bin number
    first = round(loudest - binWidth);      % get the outermost neighbor on the left
    last = round(loudest + binWidth);       % get the outermost neighbor on the right
    bins = [bins(1:n); setdiff(bins(n + 1:end), first:last, 'stable')]; % remove all neighbors
    n = n + 1;                              % on to the next one...
end

% remove bins that have louder neighbors
n = length(bins);
while n > 0
    bin = bins(n);                          % get the nth loudest bin number
    prevBin = max(bin - 1, 1);              % get the nearest neighbor on the left
    nextBin = min(bin + 1, nfft);           % get the nearest neighbor on the right
    if X(bin) < max(X(prevBin), X(nextBin)) % if the this bin is quieter than either of it's neighbors...
        bins(n) = [];                       % ... then it's not a real peak
    end
    n = n - 1;                              % on to the next one...
end

% remove extra bins
if maxNumPeaks > 0
    bins = bins(1:min(maxNumPeaks, length(bins)));
end

%% organize and print out results
loudestFreqs = bin_to_freq(bins, fs, nfft); % convert bin numbers to frequencies
magnitudes = X(round(bins));                % get the loudnesses of the peaks
if ~normalizeResults
    maxDB = gain_to_dB(max(abs(x)));
    magnitudes = magnitudes + maxDB;
    X = X + maxDB;
end

% print results
disp(['peaks in ' soundfile ', sorted by loudness...']);
for n = 1:length(loudestFreqs)
    disp([num2str(n), ', ',  num2str(loudestFreqs(n)), ', ', num2str(dB_to_gain(magnitudes(n)))]);
end

%% plot
clf;
faxis = linspace(1, nyquist, nfft / 2)';
plot(faxis, dB_to_gain(X));
% axis([0, nyquist, (noiseFloor - 12), max(X) + 3]);
hold all;
plot(loudestFreqs, dB_to_gain(magnitudes), 'v');
