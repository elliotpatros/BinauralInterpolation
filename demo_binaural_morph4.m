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

% for plotting, delete later
plotx1 = [1:Ndb; 1:Ndb; 1:Ndb]';
plotx2 = M';
ploty2 = [zeros(1, length(M)); ones(1, length(M))];
plotz2 = [YM1, YM2];

%% step 3b, morph
clf;
pause;
for weight = linspace(0, 1, 200)
newYdb = zeros(size(Ydb1));
Yindex = 2;
for e = 2:length(M) - 1
    b = e - 1;
    
    % test quadrilateral
    bEdge = weighted_mean(M(b,1), M(b,2), weight);
    eEdge = weighted_mean(M(e,1), M(e,2), weight);
    % if the current x,y intersect with this quadrilateral
    if bEdge <= Yindex && Yindex <= eEdge
        % definition of plane
        A = [M(b, 1), 0, YM1(b)];
        B = [M(e, 1), 0, YM1(e)];
        C = [M(b, 2), 1, YM2(b)];
        D = [M(e, 2), 1, YM2(e)];
        
        % is our point in triangle 2 (BCD) ?
        if P_in_triangle([Yindex, weight], B, C, D)
            A = D;
        end
        
        % find z on plane given x, y
        v1 = A - B;
        v2 = A - C;
        cp = cross(v1, v2);
        K = cp(1)*A(1) + cp(2)*A(2) + cp(3)*A(3);
        z = (1/cp(3)) * (K - cp(1)*Yindex - cp(2)*weight);
        
        % record answer
        newYdb(Yindex) = z;
        Yindex = Yindex + 1;
    end
end

newYdb(1) = weighted_mean(Ydb1(1), Ydb2(1), weight);
newYdb(end) = weighted_mean(Ydb1(end), Ydb2(end), weight);

%\cleanup
clear Yindex e b bEdge eEdge A B C D v1 v2 cp K z;

%% plot
subplot(3, 1, [1, 2]);
ploty1 = [zeros(Ndb, 1), ones(Ndb, 1) * weight, ones(Ndb, 1)];
plotz1 = [Ydb1, newYdb, Ydb2];
plot3(plotx1, ploty1, plotz1, 'r.', 'MarkerSize', 20); hold on;
plot3(plotx2, ploty2, plotz2, 'k:');
view(0, 35);
% view(-90, 90);
hold off;
subplot(313);
plot(plotz1);
drawnow;

end

%\cleanup
clear x y z plotx1 plotx2 ploty1 ploty2 plotz1 plotz2;
