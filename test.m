% description
% 
% expand newYdb into fft of length nfft.
% use real and imaginary parts to crossfade phase.
% plot ifft of result.

%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
weight = 1;

azim1 = 0;
elev1 = 0;
azim2 = 5;
elev2 = 0;

dur = 1;

%% load audio
% get binaural signals (time domain)
[l1, r1, fs] = load_binaural(azim1, elev1);
[l2, r2] = load_binaural(azim2, elev2);

% get source sound
x = make_noise(1, dur * fs, 1);
L = length(x);

%% try 3
Yl1 = do_morph([l1; zeros(L-200, 1)], [l2; zeros(L-200, 1)], weight);
Yr1 = do_morph([r1; zeros(L-200, 1)], [r2; zeros(L-200, 1)], weight);

% subplot(211);
% plot(Yl1

% y(:, 1) = ifft(Yl1 .* fft(x));
% y(:, 2) = ifft(Yr1 .* fft(x));
% 
% plot(fliplr(y));
% soundsc(y, fs);

% %% try 2
% % do fft
% Yl1 = abs(fft(l1, L));
% Yr1 = abs(fft(r1, L));
% 
% y(:, 1) = ifft(Yl1 .* fft(x));
% y(:, 2) = ifft(Yr1 .* fft(x));
% 
% plot(y);
% soundsc(y, fs);

%% try 1
% %% do fft
% Yl1 = abs(fft(l1));
% Yr1 = abs(fft(r1));
% 
% win = (1:L)';
% hop = L / 2;
% h_win = hanning(L);
% 
% y = zeros(length(x), 2);
% while win(end) < Lx
%     y(win, 1) = y(win, 1) + ifft(Yl1 .* abs(fft(x(win)))) .* h_win;
%     y(win, 2) = y(win, 2) + ifft(Yr1 .* abs(fft(x(win)))) .* h_win;
%     win = win + hop;
% end
% 
% plot(y)
% soundsc(y, fs);
