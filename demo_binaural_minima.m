%
% try to pick entire hills. local min and max
%
%

%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
az = 5;
el = 0;

%% load audio
[x, ~, fs] = load_binaural(az, el);

%% pick peaks
% get fft
L = length(x);
N = 2^nextpow2(L);
Y = fft(x, N);
Yr = abs(Y);
Yi = imag(Y);
Ydb = gain_to_dB(Yr(1:end/2));
Ndb = length(Ydb);

% pick peaks
nPeaks = 0;
peaks = zeros(Ndb, 1);
n = 2;
while n < Ndb
    if Ydb(n) > max(Ydb(n - 1), Ydb(n + 1))
        nPeaks = nPeaks + 1;
        peaks(nPeaks) = n;
        n = n + 2;
    else
        n = n + 1;
    end
end

peaks = peaks(1:nPeaks);

% peak peak boundaries
boundaries = zeros(nPeaks, 2);
limits = [1; peaks; Ndb];
for n = 1:nPeaks    
    lhs = limits(n);
    rhs = limits(n + 1);
    [~, l] = min(Ydb(lhs:rhs));
    l = l + (lhs - 1);
    
    lhs = limits(n + 1);
    rhs = limits(n + 2);
    [~, r] = min(Ydb(lhs:rhs));
    r = r + (lhs - 1);
    boundaries(n, :) = [l r];
    
    plot(Ydb); hold on;
    plot(peaks, Ydb(peaks), 'ro', 'MarkerSize', 10);
    plot(l, Ydb(l), 'g*');
    plot(r, Ydb(r), 'r*'); hold off;
    drawnow;
    pause;
end
