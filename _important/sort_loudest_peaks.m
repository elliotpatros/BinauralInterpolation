function loudestPeaks = sort_loudest_peaks(Y, peaks)
%SORT_LOUDEST_PEAKS sorts peaks from loudest to quietest

[~, sorted] = sort(Y(peaks), 'descend');
loudestPeaks = peaks(sorted);

end

