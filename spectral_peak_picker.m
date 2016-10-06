function Xstruct = spectral_peak_picker(x, fs, noiseFloor, minPeakDistance)
% SPECTRAL_PEAK_PICKER Finds and plots peaks in a spectrum
%
% x is the input signal (should be mono)
% fs is the sampling frequency
% noiseFloor is the minimum loudness for something to be a peak (dB)
% minPeakDistance is the expected with of side lobes (Hz)

%% bake input signal
% get pow2 length of fft
nfft = 2^nextpow2(length(x));

% get real fft
X = abs(fft(x, nfft));

% normalize
X = X ./ nfft;

% don't use bins over nyquist
X = X(1:end/2);
nBins = length(X);

% convert to dB
X = gain_to_dB(X);


%% remove anything that isn't a peak

% filter out bins that are quieter than the noise floor
Xstruct = [];
for bin = 1:nBins
    if X(bin) >= noiseFloor
        Xstruct = [Xstruct, struct('bin', bin, 'mag', X(bin))];
    end
end

% sort peaks from loudest to quietest
[~, order] = sort([Xstruct(:).mag], 'descend');

% remove any peaks that are within minPeakDistance of louder peaks
currentPeak = 1;
minPeakDistanceInBins = freq_to_bin(minPeakDistance, fs, nfft);
while currentPeak <= length(Xstruct)
    loudestBin = Xstruct(order(currentPeak)).bin;
    startingBin = max(round(loudestBin - minPeakDistanceInBins), 1);
    endingBin = min(round(loudestBin + minPeakDistanceInBins), length(Xstruct));
    binRange = endingBin:-1:startingBin;
    for quieterBin = binRange(binRange ~= loudestBin)
        Xstruct(quieterBin)=[];
    end
    currentPeak = currentPeak + 1;
end

%% plot
% faxis = linspace(0, nyquist, nfft / 2)';
% loglog(faxis, X);
% axis([0 nyquist -96 0])

end

