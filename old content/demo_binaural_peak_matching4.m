%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
azim1 = 50;
elev1 = 0;
azim2 = 55;
elev2 = 0;

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
M = [1; zeros(Ndb-2, 1); Ndb];

% find distances between peaks. 
% starting with the loudest source peak, pick the nearest target pick
fCost = 2;
mCost = 1;
maxDistance = Ndb * max([1, fCost, mCost]);

% find best match for nth loudest peak
for n = 1:nPeaks1
    bestMatch = [0, maxDistance];   % searching placeholder [bestIndex, bestValue]
    p1 = [peaks1(s(n)), Ydb1(peaks1(s(n)))];  % nth loudest peak [index, mag]
    
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
    % ...and if this match hasn't been made yet, save it
    if isempty(M(M==peaks2(bestMatch(1))))
        M(peaks1(s(n))) = peaks2(bestMatch(1));
    end
end

% fix any crossed matches
M(M~=0) = sort(M(M~=0));

%\cleanup
clear s fCost mCost maxDistance bestMatch n k p1 p2 D;

%% step 2b, find best min match between peaks
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

%% step 2c, expand m
% so the general idea is to interpolate bins between important matched
% features. i should go, a feature at a time, and fill in the blanks.
temp = allMatches(1,:);
for n = 2:length(allMatches)
    b1 = allMatches(n - 1, 1);
    e1 = allMatches(n,     1);
    b2 = allMatches(n - 1, 2);
    e2 = allMatches(n,     2);
    
    L1 = (e1 - b1) + 1;
    L2 = (e2 - b2) + 1;
    newL = max(L1, L2);
    
    intermediateMatches = [linspace(b1,e1,newL)', linspace(b2,e2,newL)'];
    temp = [temp; intermediateMatches(2:end,:)];
end

M = temp;
% intermediateMatches1 = setdiff(M(:,1), allMatches(:,1), 'stable');
% intermediateMatches2 = setdiff(M(:,2), allMatches(:,2), 'stable');

%\cleanup
clear temp n b1 e1 b2 e2 L1 L2 newL intermediateMatches;

%% morph
YM1 = linear_interpolation(Ydb1, M(:,1));
YM2 = linear_interpolation(Ydb2, M(:,2));

%% plot
xNdb = (1:Ndb)';
yDb = ones(Ndb, 1);
ym = ones(length(allMatches), 1);
ya = ones(length(M), 1);
Ydbs = [Ydb1, Ydb2];

plot3([xNdb,xNdb], [yDb*0,yDb], Ydbs, '-', 'LineWidth', 2); 
hold on;
plot3(M', [ya*0, ya]', [YM1, YM2], 'k:');
plot3(allMatches(:,1)', ym'*0, Ydb1(allMatches(:,1)), 'k.', 'MarkerSize', 20);
plot3(allMatches(:,2)', ym', Ydb2(allMatches(:,2)), 'k.', 'MarkerSize', 20);
plot3(allMatches', [ym*0, ym]', [Ydb1(allMatches(:,1)), Ydb2(allMatches(:,2))], 'k');

axis([0, Ndb+1, -0.05, 1.05, min(min(Ydbs-3)), max(max(Ydbs+3))]);
view(0, 35);
hold off;

%\cleanup
clear xNdb yDb ym ya Ydbs;
