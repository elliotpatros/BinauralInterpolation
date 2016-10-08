clearvars;
addpath(genpath('.'));

%% user input
azim1 = 5;
elev1 = 0;
azim2 = 15;
elev2 = 0;

%% get audio
[x1, ~, fs] = load_binaural(azim1, elev1);
x2 = load_binaural(azim2, elev2);

%% pick peaks
[Y1, peaks1] = pick_peaks(x1, fs);
[Y2, peaks2] = pick_peaks(x2, fs);


%% SPECTRAL MORPH
%% user stuff
weight = 0.5;

%% find which fft has fewer peaks (match from fewer to more)
nBins = length(Y1);
nPeaks1 = length(peaks1);
nPeaks2 = length(peaks2);
hasFewer = 1;

if nPeaks2 < nPeaks1
    hasFewer = 2;
end

%% match peaks
if hasFewer == 1
    sourcePeaks = peaks1;
    sourceY = Y1;
    targetPeaks = peaks2;
    targetY = Y2;
else
    sourcePeaks = peaks2;
    sourceY = Y2;
    targetPeaks = peaks1;
    targetY = Y1;
end
    
% find closest peak to nth loudest partial
%%
plot_peaks(Y1, peaks1, fs);
hold on;
plot_peaks(Y2, peaks2, fs);
hold on;
drawnow;

%%
BIN = 1; MAG = 2;
newPeaks = zeros(length(sourcePeaks), 2);
n = 1;
while n < length(sourcePeaks)
    % find the closest target peak to the nth loudest source peak
    sourceBin = sourcePeaks(n);
    [~, c] = min(abs(targetPeaks - sourceBin));
    
    % interpolation bin and magnitude
    targetBin = targetPeaks(n);
    sourceMag = sourceY(sourceBin);
    targetMag = targetY(targetBin);
    newPeaks(n, BIN) = lin_int([sourceBin, targetBin], weight);
    newPeaks(n, MAG) = lin_int([sourceMag, targetMag], weight);
    
    plot(bin_to_freq(newPeaks(n, BIN), fs, nBins * 2), newPeaks(n, MAG), '*');
    hold on;
    drawnow;
    pause;
    
    
    n = n + 1;
end
% BIN = 1; MAG = 2;
% nFewerPeaks = length(sourcePeaks);
% newPeaks = zeros(nFewerPeaks, 2); % bin, mag
% n = 1;
% while n < length(sourcePeaks)
%     % find closest bin to source
%     sourceBin = sourcePeaks(n);
%     [~, c] = min(abs(targetPeaks - sourceBin));
%     
%     % interpolate bin and magnitude by weight
%     targetBin = targetPeaks(c);
%     sourceMag = sourceY(sourceBin);
%     targetMag = targetY(targetBin);
%     newPeaks(n, BIN) = lin_int([sourceBin, targetBin], weight);
%     newPeaks(n, MAG) = lin_int([sourceMag, targetMag], weight);
%     n = n + 1;
% end



%% plot
% plot_peaks(Y1, peaks1, fs);
% hold on;
% plot_peaks(Y2, peaks2, fs);
hold on;
plot(bin_to_freq(newPeaks(:, BIN), fs, nBins * 2), newPeaks(:, MAG), '*');
hold off;

%% crossfade residual

















