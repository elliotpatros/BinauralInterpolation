%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
weight = 1;

azim1 = 0;
elev1 = 0;
azim2 = 5;
elev2 = 0;

%% load audio
% get binaural signals (time domain)
x1 = load_binaural(azim1, elev1);
x2 = load_binaural(azim2, elev2);
L = length(x1);

%% do fft
nfft = L;
Ndb = nfft / 2 + 1;
Y1 = fft(x1, nfft);
Y2 = fft(x2, nfft);
Ydb1 = gain_to_dB(abs(Y1(1:Ndb)));
Ydb2 = gain_to_dB(abs(Y2(1:Ndb)));
Yph1 = unwrap(angle(Y1(1:Ndb)));
Yph2 = unwrap(angle(Y2(1:Ndb)));

%% find peaks
peaks1 = pick_peaks(Ydb1);
peaks2 = pick_peaks(Ydb2);
nPeaks1 = length(peaks1);
nPeaks2 = length(peaks2);

%% match peaks
% setup matching
[~, s] = sort(Ydb1(peaks1), 'descend');
M = [1; zeros(Ndb-2, 1); Ndb];
fCost = 2;
mCost = 1;
maxDistance = Ndb * max([1, fCost, mCost]);

% find best match for nth loudest peak
for n = 1:nPeaks1
    bestMatch = [0, maxDistance];
    p1 = [peaks1(s(n)), Ydb1(peaks1(s(n)))];
    for k = 1:nPeaks2
        p2 = [peaks2(k), Ydb2(peaks2(k))];
        D = weighted_distance(p1, p2, [fCost, mCost]);
        if D < bestMatch(2)
            bestMatch = [k, D];
        end
    end
    
    if isempty(M(M==peaks2(bestMatch(1))))
        M(peaks1(s(n))) = peaks2(bestMatch(1));
    end
end

% fix any crossed matches
M(M~=0) = sort(M(M~=0));

%\cleanup
clear s fCost mCost maxDistance bestMatch n k p1 p2 D;

%% find best min match between peaks
lastPeak = 1;
for n = 2:length(M)
    if M(n) == 0; continue; end;
    
    [~, v1] = min(Ydb1(lastPeak:n));
    [~, v2] = min(Ydb2(M(lastPeak):M(n)));
    
    v1 = v1 + (lastPeak - 1);
    v2 = v2 + (M(lastPeak) - 1);
    
    notLast1 = v1 ~= lastPeak;
    notLast2 = v2 ~= M(lastPeak);
    notThis1 = v1 ~= n;
    notThis2 = v2 ~= M(n);
    
    if notLast1 && notLast2 && notThis1 && notThis2
        M(v1) = v2;
    end
    
    lastPeak = n;
end

% compress all matches
allMatches = [find(M~=0), M(M~=0)];

%\cleanup
clear n v1 v2 lastPeak notLast1 notLast2 notThis1 notThis2;

%% step 2c, expand M
% so the general idea is to interpolate bins between important matched
% features. i should go a feature at a time, and fill in the blanks.
% my original attempt at this left out some integers in M, for example, a
% section of M might look like [5, 5; 6, 5.8; 7, 6.6]. Though scaled
% correctly, this meant that the surfaces I use for morphing smoothed away
% curves. now, i make that M has all integers between 1 and Ndb, and their
% matched indexes.
temp = allMatches(1,:);
for n = 2:length(allMatches)
    b1 = allMatches(n - 1, 1);
    e1 = allMatches(n,     1);
    b2 = allMatches(n - 1, 2);
    e2 = allMatches(n,     2);
    
    L1 = (e1 - b1);
    L2 = (e2 - b2);
    newL = max(L1, L2) + 1;
    
    l1 = linspace(b1, e1, newL)';
    l2 = linspace(b2, e2, newL)';
    
    i1 = setdiff(b1:e1, l1)';
    i2 = setdiff(b2:e2, l2)';
    
    if ~isempty(i1)
        i2 = ((i1 - b1) * L2 / L1) + b2;
    elseif ~isempty(i2)
        i1 = ((i2 - b2) * L1 / L2) + b1;
    end
    
    l1 = sort([l1; i1]);
    l2 = sort([l2; i2]);
    
    temp = [temp; [l1(2:end), l2(2:end)]];
end

M = temp;

%\cleanup
clear temp n b1 e1 b2 e2 L1 L2 newL l1 l2 i1 i2;

%% step 3a, make interpolated Ydb's
YM1 = linear_interpolation(Ydb1, M(:,1));
YM2 = linear_interpolation(Ydb2, M(:,2));