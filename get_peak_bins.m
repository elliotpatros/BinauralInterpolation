function peaks = get_peak_bins(Y, noiseFloor)
%GET_PEAKS finds all valid peaks over threshold (dB)
% returns a list of peak locations (bins)

nBins = length(Y);                          % how many freqs does Y have
peaks = zeros(nBins, 1);                    % we'll store peaks in this list
nPeaksFound = 0;                            % how many peaks have we found?
n = 2;                                      % start searching after 0 Hz
while n < nBins                             % search for peaks between 0-nyquist
    
    isLoudEnough = Y(n) > noiseFloor;       % is this peak louder than the threshold?
    isPeak = Y(n) > max(Y(n-1), Y(n+1));    % is this peak louder than it's neighbors?
    
    if isLoudEnough && isPeak               % if all of the above is true...
        nPeaksFound = nPeaksFound + 1;      % ... then we found one!
        peaks(nPeaksFound) = n;             % ... write it down
        n = n + 2;                          % ... don't check the next one
    else
        n = n + 1;                          % we didn't find one, keep going
    end
end

peaks = peaks(1:nPeaksFound);               % get rid of extra zeros

end
