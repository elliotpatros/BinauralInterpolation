function loudestBins = spectral_peak_picker(X, fs, noiseFloor, minPeakDistance)
% SPECTRAL_PEAK_PICKER Finds and plots peaks in a spectrum
%
% X is a real fft
% fs is the sampling frequency
% noiseFloor is the minimum loudness for something to be a peak (dB)
% minPeakDistance is the expected with of side lobes (Hz)

%% remove anything that isn't a peak
% sort bins from loudest to quietest
[~, loudestBins] = sort(X, 'descend');
nfft = length(X);
% remove bins that are below the loudness threshold
loudestBins = loudestBins(X(loudestBins) >= noiseFloor);

% remove any peaks that are within minPeakDistance of louder peaks
currentPeak = 1;
minBinDistance = freq_to_bin(minPeakDistance, fs, nfft);
while currentPeak <= length(loudestBins)
    loudestBin = loudestBins(currentPeak);
    startingBin = round(loudestBin - minBinDistance);
    endingBin = round(loudestBin + minBinDistance);
    binRange = startingBin:endingBin;
    loudestBins = [loudestBins(1:currentPeak); setdiff(loudestBins(currentPeak + 1:end), binRange, 'stable')];
    currentPeak = currentPeak + 1;
end

% remove any peaks that have louder neighbors
for n = length(loudestBins):-1:1
    bin = loudestBins(n);
    nextBin = min(bin + 1, nfft);
    prevBin = max(bin - 1, 1);
    if X(bin) < X(nextBin) || X(bin) < X(prevBin)
        loudestBins(bin) = [];
    end
end


end

