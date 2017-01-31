%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
az1 = 50;
el1 = 0;
az2 = 55;
el2 = 0;

%% load audio
x1 = load_binaural(az1, el1);
x2 = load_binaural(az2, el2);

%% do fft
L = length(x1);
nfft = L; %2^nextpow2(L);

% get fft
Y1 = fft(x1, nfft);
Y2 = fft(x2, nfft);

% get real part and below nyquist
Yr1 = abs(Y1(1:end/2));
Yr2 = abs(Y2(1:end/2));

% convert to dB
Ydb1 = gain_to_dB(Yr1);
Ydb2 = gain_to_dB(Yr2);
Ndb = length(Ydb1);

%% step 1, find binaural hills
% get peaks
peaks1 = pick_peaks(Ydb1);
peaks2 = pick_peaks(Ydb2);
nPeaks1 = length(peaks1);
nPeaks2 = length(peaks2);

%% step 2, match peaks
% sort by loudest
[~, s] = sort(Ydb1(peaks1), 'descend');

% match nearest neighbors
% at m(n), Ydb1(n) <-> Ydb2(m(n))
m = zeros(Ndb, 1);
m(1) = 1;
m(Ndb) = Ndb;

% we're going try to do a cost-based nearest neighbor peak matcher.
fCost = 2;      % cost of frequency-distance (scalar)
mCost = 1;      % cost of magnitude-distance (scalar)
maxDistance = Ndb * max([1 fCost mCost]);

% find best match for nth loudest peak
for n = 1:nPeaks1
    % place holder for nearest neighbor (index, distance)
    bestMatch = [0, maxDistance];
    
    % position of the nth loudest peak in peaks1
    thisPeak = peaks1(s(n));
    p1 = [thisPeak, Ydb1(thisPeak)];
    for k = 1:nPeaks2
        % position of the kth peak in peaks2
        p2 = [peaks2(k) Ydb2(peaks2(k))];
        
        % distance between p1 and p2
        D = weighted_distance(p1, p2, [fCost, mCost]);
        
        if D < bestMatch(2)
            bestMatch = [k, D];
        end
    end
    
    bestPeakIndex = peaks2(bestMatch(1));
    if isempty(m(m==bestPeakIndex))
        m(thisPeak) = bestPeakIndex;
    end
end

m(m~=0) = sort(m(m~=0)); % fix any crossed matches

%\cleanup
clear s fCost mCost maxDistance bestMatch n k p1 p2 thisPeak D bestPeakIndex;

% find best match for valleys
lastPeak = 1;
for n = 2:length(m)
    if m(n) == 0; continue; end;
    
    [~, v1] = min(Ydb1(lastPeak:n));
    [~, v2] = min(Ydb2(m(lastPeak):m(n)));
    
    v1 = v1 + (lastPeak - 1);
    v2 = v2 + (m(lastPeak) - 1);

    notLast1 = v1 ~= lastPeak;
    notLast2 = v2 ~= m(lastPeak);
    notThis1 = v1 ~= n;
    notThis2 = v2 ~= m(n);
    
    if notLast1 && notLast2 && notThis1 && notThis2
        m(v1) = v2;
    end
    
    lastPeak = n;
end

%\cleanup
clear n v1 v2 lastPeak notLast1 notLast2 notThis1 notThis2;

% compress m
% now, Ydb1(m(n, 1)) matches Ydb2(m(n, 2))
nFeatures = 0;
temp = zeros(length(m), 2);
for n = 1:length(m)
    if m(n) == 0; continue; end;
    nFeatures = nFeatures + 1;
    temp(nFeatures, :) = [n, m(n)];
end
m = temp(1:nFeatures, :);

%\cleanup
clear n temp nFeatures;

%% plot
moveby = 40;
Ydb2 = Ydb2 - moveby; % move this down to see better

minx = 0; maxx = Ndb + 1;
miny = min([Ydb1; Ydb2]) - 3; maxy = max([Ydb1; Ydb2]) + 3;

plot(Ydb1, 'Color', 'b'); hold on; axis([minx maxx miny maxy]);
plot(Ydb2, 'Color', 'r');

for n = 1:length(m(:,1))
    plot(m(n,1), Ydb1(m(n,1)), 'bo');
    plot(m(n,2), Ydb2(m(n,2)), 'ro');
    plot(m(n,:), [Ydb1(m(n,1)) Ydb2(m(n,2))], 'k:');    
end

hold off;
Ydb2 = Ydb2 + moveby;

%\cleanup
clear moveby minx maxx miny maxy n















































