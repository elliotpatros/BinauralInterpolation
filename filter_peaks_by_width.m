function sorted = filter_peaks_by_width(Y, peakBins, minWidth, fs, nfft)
% FILTER_PEAKS_BY_WIDTH removes peaks within minWidth of louder peaks
%   Y - fft signal
%   peakBins - sorted list of bins that are peaks
%   fs - sampling rate
%   minWidth - minimum peak width (Hz.)

sorted = peakBins;
if minWidth > 0
    nBins = length(Y);                              % get number of bins
    width = freq_to_bin(minWidth, fs, nfft);        % get min width of a peak
    n = 1;                                          
    while n <= length(sorted)
        loudest = sorted(n);                        % get the nth loudest bin
        first = max(round(loudest - width), 1);     % get the farthest bin to the left
        last = min(round(loudest + width), nBins);  % get the farthest bin to the right
        sorted = [sorted(1:n); setdiff(sorted(n+1:end), first:last, 'stable')]; % remove all neighbors
        n = n + 1;                                  % on to the next one
    end

end
end

