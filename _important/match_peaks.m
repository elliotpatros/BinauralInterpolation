function matched = match_peaks(source, target, minDistance)

%% assign to nearest neighbor
maxNumPeaks = length(source);
matched = zeros(maxNumPeaks, 1);
for n = 1:maxNumPeaks
    [~, c] = min(abs(target - source(n)));
    if abs(source(n) - target(c)) < minDistance
        matched(n) = c;
    end
end
end

