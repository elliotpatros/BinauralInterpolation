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

%% plot
nFrames = 100;
x = (1:Ndb)';       % freq bins
y = ones(Ndb, 1);   % weight
z = [Ydb1, Ydb2];   % magnitude

axis3d = [1 Ndb 0 1 min(min(z - 3)) max(max(z + 3))];
close all; 
winhandle = 1;
figure(winhandle);
set(winhandle, 'Name', 'press any key');
pause;
set(winhandle, 'Name', 'crossfade');

vazims = linspace(-4, 4, nFrames);
weights = linspace(0, 1, nFrames);
for n = 1:nFrames
    weight = weights(n);
    newY = weighted_mean(Ydb1, Ydb2, weight);
    
    subplot(3, 1, [1, 2]);
    axis(axis3d);
    plot3(x, y*weight, newY, 'k-'); hold on;
    surf([x, x], [y*0, y*1], z);     
    view(vazims(n), 30);
    hold off;

    subplot(313);
    plot(x, [Ydb1, Ydb2, weighted_mean(Ydb1, Ydb2, weight)]);
    drawnow;
end

clear nFrames x y z axis3d winhandle vazims weights n weight newY;

%% a la HRTF interpolation paper