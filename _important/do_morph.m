function newx = do_morph(x1, x2, weight)

%% do fft
nfft = length(x1);
Ndb = nfft / 2 + 1;
Y1 = fft(x1, nfft);
Y2 = fft(x2, nfft);
Ydb1 = gain_to_dB(abs(Y1(1:Ndb)));
Ydb2 = gain_to_dB(abs(Y2(1:Ndb)));
Yph1 = unwrap(angle(Y1(1:Ndb)));
Yph2 = unwrap(angle(Y2(1:Ndb)));

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

%% step 3b, morph
newYdb = zeros(size(Ydb1));
Yindex = 2;
FREQ = 1; MAG = 2;  % helper indices
for e = 2:length(M) - 1
    b = e - 1;
    
    % this surface (corner points)
    % b === beginning (closer to bin 1)
    % e === ending (closer to bin Ndb)
    % suffix 1 is for weight = 0
    % suffix 2 is for weight = 1
    % finally, as a note, B1(1) is the frequency, B1(2) is the magnitude,
    % weight is not in here, but it should be. the problem is flattened in
    % the representation below.
    B1 = [M(b, 1), YM1(b)];
    E1 = [M(e, 1), YM1(e)];
    B2 = [M(b, 2), YM2(b)];
    E2 = [M(e, 2), YM2(e)];
    
    % points between line segments that connect Y1 to Y2
    bPoint = weighted_mean(B1, B2, weight);
    ePoint = weighted_mean(E1, E2, weight);
    
    % if the new Y index that we're looking for is between this line
    % segment, then figure out the elevation (or magnitude) at the point
    % (Yindex, weight, elevation).
    if bPoint(FREQ) <= Yindex && Yindex <= ePoint(FREQ)
        slope = (ePoint(MAG) - bPoint(MAG)) / (ePoint(FREQ) - bPoint(FREQ));
        newYdb(Yindex) = slope * (Yindex - bPoint(FREQ)) + bPoint(MAG);
        Yindex = Yindex + 1;
    end
end

newYdb(1) = weighted_mean(Ydb1(1), Ydb2(1), weight);
newYdb(end) = weighted_mean(Ydb1(end), Ydb2(end), weight);

%\cleanup
clear Yindex FREQ WEIGHT MAG e b B1 E1 B2 E2 bPoint ePoint slope;

%% return result
newMag = dB_to_gain(newYdb);
newMag = [newMag; newMag(end-1:-1:2)];
newPhase = weighted_mean(Yph1, Yph2, weight);
newPhase = [newPhase; -1.*newPhase(end-1:-1:2)];

newx = fdosc_bank(newMag, newPhase);

end
