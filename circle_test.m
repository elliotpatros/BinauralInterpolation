%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
azim1 = 50;
elev1 = 0;
azim2 = 55;
elev2 = 0;
weight = 0.5;

%% load audio
x1 = load_binaural(azim1, elev1);
x2 = load_binaural(azim2, elev2);

%% do fft
% get lengths of input signals
L = length(x1);
nfft = L;

% complex fft
Y1 = fft(x1, nfft);
Y2 = fft(x2, nfft);

% real part
Yr1 = abs(Y1(1:end/2));
Yr2 = abs(Y2(1:end/2));

% imaginary part
Yi1 = imag(Y1);
Yi2 = imag(Y2);

% convert real part to dB
Ydb1 = gain_to_dB(Yr1);
Ydb2 = gain_to_dB(Yr2);
Ndb = length(Ydb1);

%% step 1, find peaks
peaks1 = pick_peaks(Ydb1);
peaks2 = pick_peaks(Ydb2);
nPeaks1 = length(peaks1);
nPeaks2 = length(peaks2);

%% step 2a, match peaks
% sort by loudest
[~, s] = sort(Ydb1(peaks1), 'descend');

% match nearest neighbors
% at m(n), Ydb1(n) matches Ydb2(m(n))
m = zeros(Ndb, 1);
m(1) = 1;
m(Ndb) = Ndb;

% find distances between peaks. 
% starting with the loudest source peak, pick the nearest target pick
fCost = 2;
mCost = 1;
maxDistance = Ndb * max([1, fCost, mCost]);

% find best match for nth loudest peak
for n = 1:nPeaks1
    bestMatch = [0, maxDistance];   % searching placeholder [bestIndex, bestValue]
    nthPeak = peaks1(s(n));         % nth loudest peak index
    p1 = [nthPeak, Ydb1(nthPeak)];  % nth loudest peak [index, mag]
    
    % search for the nearest peak
    for k = 1:nPeaks2
        p2 = [peaks2(k), Ydb2(peaks2(k))]; % kth target peak [index, mag]
        D = weighted_distance(p1, p2, [fCost, mCost]); % distance from p1 to p2
        
        % if the kth peak is closest so far, save the index and mag
        if D < bestMatch(2)
            bestMatch = [k, D];
        end
    end
    
    % save the closest peak by index...
    bestPeakIndex = peaks2(bestMatch(1));
    % ...and if this match hasn't been made yet, save it
    if isempty(m(m==bestPeakIndex))
        m(nthPeak) = bestPeakIndex;
    end
end

% fix any crossed matches
m(m~=0) = sort(m(m~=0));

%\cleanup
clear s fCost mCost maxDistance bestMatch n k p1 p2 nthPeak D bestPeakIndex;

%% step 2b, find best min match between peaks
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

%% step 2c, compress m
% now, Ydb1(m(n, 1)) matches Ydb2(m(n, 2))
nFeatures = 0;
tempM = zeros(length(m), 2);
for n = 1:length(m)
    if m(n) == 0; continue; end;
    nFeatures = nFeatures + 1;
    tempM(nFeatures, :) = [n, m(n)];
end
m = tempM(1:nFeatures, :);

%\cleanup
clear n tempM;

%% step 3, interpolate sections
nSections = nFeatures - 1;
newYdb = zeros(size(Ydb1));

% section start index
b1 = 1;
b2 = 1;
newB = round(weighted_mean(b1, b2, weight));

% interpolate first sample in section
newYdb(newB) = weighted_mean(Ydb1(b1), Ydb2(b2), weight);
for section = 1:nSections
    % section end index
    e1 = m(section + 1, 1);
    e2 = m(section + 1, 2);
    newE = round(weighted_mean(e1, e2, weight));
    
    % get section scale
    scale1 = length(b1:e1) / length(newB:newE);
    scale2 = length(b2:e2) / length(newB:newE);
    
    % interpolate middle samples in section
    for n = newB + 1:newE - 1
        v1 = cub_int(Ydb1, (n - newB) * scale1 + newB);
        v2 = cub_int(Ydb2, (n - newB) * scale2 + newB);
        newYdb(n) = weighted_mean(v1, v2, weight);
    end
    
    % interpolate end sample in section
    newYdb(newE) = weighted_mean(Ydb1(e1), Ydb2(e2), weight);
    
    % setup section start for next loop
    b1 = e1;
    b2 = e2;
    newB = round(weighted_mean(b1, b2, weight));
end

%\cleanup
clear nFeatures nSections b1 b2 newB section e1 e2 newE scale1 scale2 n v1 v2

%% plot
plot([Ydb1, Ydb2, newYdb]);
