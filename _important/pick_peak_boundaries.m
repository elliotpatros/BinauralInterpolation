function [boundaries] = pick_peak_boundaries(Ydb, peaks)

Ndb = length(Ydb);
nPeaks = length(peaks);
boundaries = zeros(nPeaks, 2);
limits = [1; peaks; Ndb];
for n = 1:nPeaks
    % find index of valley to left of nth peak
    lhs = limits(n);
    rhs = limits(n + 1);
    [~,l] = min(Ydb(lhs:rhs));
    l = l + (lhs - 1);
    
    % find index of valley to right of nth peak
    lhs = limits(n + 1);
    rhs = limits(n + 2);
    [~,r] = min(Ydb(lhs:rhs));
    r = r + (lhs - 1);
    
    % record what we found
    boundaries(n,:) = [l,r];
end

end

