%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
az1 = 50;
el1 = 0;
az2 = 55;
el2 = 0;

%% load audio
[x1, ~, fs] = load_binaural(az1, el1);
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

% get boundaries
bounds1 = pick_peak_boundaries(Ydb1, peaks1);
bounds2 = pick_peak_boundaries(Ydb2, peaks2);

%% step 2, match peaks
% sort by loudest
[~, sorted1] = sort(Ydb1(peaks1), 'descend');
[~, sorted2] = sort(Ydb2(peaks2), 'descend');

%% step 3, match nearest neighbors
% at m1(n), Ydb1(n) <-> Ydb2(m1(n))
m = zeros(Ndb, 1);
m(1) = 1;
m(Ndb) = Ndb;

% we're going try to do a cost-based nearest neighbor peak matcher.
fCost = 2;      % cost of frequency-distance (scalar)
mCost = 1;      % cost of magnitude-distance (scalar)
cost = [fCost, mCost];

% find best match for nth loudest peak
for n = 1:nPeaks1
    % all matches for nth peak will be stored here
    D = zeros(nPeaks2, 1);
    
    % find position 1
    thisPeak = peaks1(sorted1(n));
    p1 = [thisPeak, Ydb1(thisPeak)];
    
    % find best match for position 1
    for k = 1:nPeaks2
        p2 = [peaks2(k) Ydb2(peaks2(k))];
        D(k) = weighted_distance(p1, p2, cost);
    end
    
    % if the best match isn't already matched to something, save it
    [~, c] = min(D);
    if isempty(m(m==peaks2(c)))
        m(thisPeak) = peaks2(c);
    end
end

m(m~=0) = sort(m(m~=0)); % fix any crossed matches

%% plot
moveby = 40;
Ydb2 = Ydb2 - moveby; % move this down to see better

minx = 0; maxx = Ndb + 1;
miny = min([Ydb1; Ydb2]) - 3; maxy = max([Ydb1; Ydb2]) + 3;

plot(Ydb1, 'Color', 'b'); hold on; axis([minx maxx miny maxy]);
plot(Ydb2, 'Color', 'r');

for n = 1:Ndb
    if m(n) == 0; continue; end
    
    plot(n, Ydb1(n), 'bo');
    plot(m(n), Ydb2(m(n)), 'ro');
    plot([n m(n)], [Ydb1(n) Ydb2(m(n))], 'k:');    
end

hold off;
Ydb2 = Ydb2 + moveby;





