function peaks = pick_peaks(Ydb)

Ndb = length(Ydb);
nPeaks = 0;
peaks = zeros(Ndb, 1);

% don't look at dc or nyquist
n = 2; 
while n < Ndb
    if Ydb(n) > max(Ydb(n-1), Ydb(n+1))
        nPeaks = nPeaks + 1;
        peaks(nPeaks) = n;
        n = n + 2;
    else
        n = n + 1;
    end
end

peaks = peaks(1:nPeaks);

end

