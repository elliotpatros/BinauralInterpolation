function [Y, peakBins] = pick_peaks(x, fs)
%PICK_PEAKS picks peaks
noiseFloor = -Inf;
minPeakWidth = 0;

[Y, nfft] = do_fft(x, true);
peakBins = get_peak_bins(Y, noiseFloor);
peakBins = sort_loudest_peaks(Y, peakBins);
peakBins = filter_peaks_by_width(Y, peakBins, minPeakWidth, fs, nfft);

end

