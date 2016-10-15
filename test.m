%
% do everything...
%
% 1) find binaural hills
% 2) match hills
% 3) morph each hill
% 4) if there was a residual, cross fade that
%

%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
az1 = 5;
el1 = 0;
az2 = 10;
el2 = 0;

%% load audio
[x1, ~, fs] = load_binaural(az1, el1);
x2 = load_binaural(az2, el2);

%% do fft
L = length(x1);
nfft = 2^nextpow2(L);

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

% get boundaries
bounds1 = pick_peak_boundaries(Ydb1, peaks1);
bounds2 = pick_peak_boundaries(Ydb2, peaks2);



%% plot
maxPlotFreq = bin_to_freq(Ndb, fs, nfft);
plotPeaks1 = bin_to_freq(peaks1, fs, nfft);
plotPeaks2 = bin_to_freq(peaks2, fs, nfft);
plotBounds1 = bin_to_freq(bounds1, fs, nfft);
plotBounds2 = bin_to_freq(bounds2, fs, nfft);
faxis = linspace(0, maxPlotFreq, Ndb);

plot(faxis, Ydb1); hold on;
plot(faxis, Ydb2);

plot(plotPeaks1, Ydb1(peaks1), 'b*', 'MarkerSize', 6);
plot(plotPeaks2, Ydb2(peaks2), 'r*', 'MarkerSize', 6);

plot(plotBounds1, Ydb1(bounds1), 'bo', 'MarkerSize', 10);
plot(plotBounds2, Ydb2(bounds2), 'ro', 'MarkerSize', 10);

hold off;








% %% pick peaks
% % get fft
% L = length(x1);
% N = 2^nextpow2(L);
% Y = fft(x1, N);
% Yr = abs(Y);
% Yi = imag(Y);
% Ydb = gain_to_dB(Yr(1:end/2));
% Ldb = length(Ydb);
% 
% % pick peaks
% nPeaks = 0;
% peaks = zeros(Ldb, 1);
% n = 2;
% while n < Ldb
%     if Ydb(n) > max(Ydb(n - 1), Ydb(n + 1))
%         nPeaks = nPeaks + 1;
%         peaks(nPeaks) = n;
%         n = n + 2;
%     else
%         n = n + 1;
%     end
% end
% 
% peaks = peaks(1:nPeaks);
% 
% % peak peak boundaries
% boundaries = zeros(nPeaks, 2);
% llimits = [1; peaks];
% rlimits = [peaks; Ldb];
% for n = 1:nPeaks
%     % find boundary to left of nth peak
%     lhs = llimits(n);
%     rhs = rlimits(n);
%     [~, l] = min(Ydb(lhs:rhs));
%     l = l + (lhs - 1);
%     
%     % find boundary to right of nth peak
%     lhs = llimits(n + 1);
%     rhs = rlimits(n + 1);
%     [~, r] = min(Ydb(lhs:rhs));
%     r = r + (lhs - 1);
%     
%     % store boundaries for nth peak
%     boundaries(n, :) = [l r];
% end
% 
% plot(Ydb); 
% hold on;
% plot(peaks, Ydb(peaks), 'ro', 'MarkerSize', 10);
% plot(boundaries, Ydb(boundaries), 'r*');
% hold off;
% 

