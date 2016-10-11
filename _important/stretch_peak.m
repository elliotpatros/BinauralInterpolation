function newPeak = stretch_peak(toStretch, newLength)
%STRETCH_PEAK Stretches a peak while maintaining local min and max

L = length(toStretch);

if L < 3
    error('toStretch must have at least 3 values');
elseif newLength < 3
    error('newLength must be at least 3');
end

newPeak = zeros(newLength, 1);
stretchBy = L / newLength;
[maximum, maxIndex] = max(toStretch);
newMaxIndex = round(maxIndex / stretchBy);

newPeak(1) = toStretch(1);
newPeak(end) = toStretch(end);
newPeak(newMaxIndex) = maximum;

for n = [2:newMaxIndex-1, newMaxIndex+1:newLength-1]
    newPeak(n) = lin_int(toStretch, n * stretchBy);
end

