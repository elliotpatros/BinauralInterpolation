%% reset
clearvars;
clc;

%% user parameters
soundfile = 'cello.aiff'; 
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
Y = abs(fft(x, nfft));                      % get real-fft of soundfile
Y = Y(1:end/2);                             % get frequencies below nyquist
Y = Y ./ max(Y);                            % normalize fft
Y = gain_to_dB(Y);                          % convert magnitude to dB.

%% pick peaks
% find possible peaks
nBins = length(Y);                          % how many freqs does Y have
peakBins = zeros(nBins, 1);                 % we'll store peaks in this list
nPeaksFound = 0;                            % how many peaks have we found?
n = 2;                                      % start searching after 0 Hz
while n < nBins                             % search for peaks between 0-nyquist
    isLoudEnough = Y(n) > noiseFloor;       % is this peak louder than the threshold?
    isPeak = Y(n) > max(Y(n-1), Y(n+1));    % is this peak louder than it's neighbors?
    if isLoudEnough && isPeak               % if both conditions are true...
        nPeaksFound = nPeaksFound + 1;      % ... then we found one!
        peakBins(nPeaksFound) = n;          % ... let's remember this!
        n = n + 2;                          % ... no need to check the next one
    else
        n = n + 1;                          % we didn't find one, keep going
    end
end

peakBins = peakBins(1:nPeaksFound);         % get rid of trailing 0's

%% organize and print out results
peakFreqs = bin_to_freq(peakBins, fs, nfft);

upperYFreq = bin_to_freq(nBins, fs, nfft);
freqAxis = linspace(0, upperYFreq, nBins)';
plot(freqAxis, Y);
hold all;
plot(peakFreqs, Y(peakBins), 'v');