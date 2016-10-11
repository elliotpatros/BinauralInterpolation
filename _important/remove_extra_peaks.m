function peaks = remove_extra_peaks(Y, peaks, nPeaks)

[~, sorted] = sort(Y(peaks), 'descend');
sorted = sorted(1:nPeaks);
peaks = sort(sorted, 'ascend');

end

