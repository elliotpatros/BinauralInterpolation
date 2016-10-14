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
Ldb = length(Ydb);

% pick peaks
nPeaks = 0;
peaks = zeros(Ldb, 1);
n = 2;
while n < Ldb
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
llimits = [1; peaks];
rlimits = [peaks; Ldb];
for n = 1:nPeaks
    plot(Ydb); 
    hold on;
    plot(peaks, Ydb(peaks), 'ro', 'MarkerSize', 10);
    
    lhs = llimits(n);
    rhs = rlimits(n);
    [~, l] = min(Ydb(lhs:rhs));
    l = l + (lhs - 1);
    plot(l, Ydb(l), 'g*');
    drawnow;
    pause;
    
    lhs = llimits(n + 1);
    rhs = rlimits(n + 1);
    [~, r] = min(Ydb(lhs:rhs));
    r = r + (lhs - 1);
    boundaries(n, :) = [l r];
    
    
    plot(r, Ydb(r), 'r*');
    hold off;
    drawnow;
    pause;
end
