%% reset
clearvars;
addpath(genpath('.'));

%% user args
az1 = 5;        % degrees
el1 = 0;        % degrees
az2 = 15;       % degrees
el2 = 0;        % degrees
weight = 0.5;   % scalar
minDist = 400;  % Hz

%% get audio
[x1, ~, fs] = load_binaural(az1, el1);
x2 = load_binaural(az2, el2);

%% pick peaks
[Y1, P1, nfft] = do_binaural_fft(x1);
s1 = sort_loudest_peaks(P1, get_peak_bins(P1, -Inf));
l1 = length(s1);

[Y2, P2] = do_binaural_fft(x2);
s2 = sort_loudest_peaks(P2, get_peak_bins(P2, -Inf));
l2 = length(s2);

%% match peaks to nearest neighbor
if l1 >= l2
    x = struct('source_bins', s1, ...
               'source_imag', Y1, ...
               'source_real', P1, ...
               'target_bins', s2, ...
               'target_imag', Y2, ...
               'target_real', P2, ...
               'longer',      1);
else
    weight = 1 - weight;
    x = struct('source_bins', s2, ...
               'source_imag', Y2, ...
               'source_real', P1, ...
               'target_bins', s1, ...
               'target_imag', Y1, ...
               'target_real', P2, ...
               'longer',      2);
end

m = match_peaks(x.source_bins, ...
                x.target_bins, ...
                freq_to_bin(minDist, fs, length(x1)));
            
%% make a new fft 
newFFT = zeros(nfft, 2);
REAL = 1;
IMAG = 2;
for n = 1:length(m)
    % from fft bin number...
    b1 = x.source_bins(n);
    
    % ...to fft bin number
    if m(n) ~= 0
        b2 = x.target_bins(m(n));
    else
        b2 = b1;
    end
    
    % get fft mags at bins
    m1 = x.source_real(b1);
    m2 = x.target_real(b2);
    
    % linearly interpolate to get new bin and new mag
    newmag = lin_int([m1 m2], weight);
    newbin = lin_int([b1 b2], weight);
    newbin = round(newbin);
    newFFT(newbin, REAL) = newFFT(newbin, REAL) + newmag;
    
    % linearly interpolate to get new phase
    ph1 = x.source_imag(b1);
    ph2 = x.target_imag(b2);
    newpha = lin_int([ph1 ph2], weight);
    newFFT(newbin, IMAG) = newFFT(newbin, IMAG) + newpha;
end

% make negative frequencies
newFFT(end/2+1:end, REAL) = flip(newFFT(1:end/2, REAL));

% get residuals
source_residual = x.source_real;
source_residual(x.source_bins) = -Inf;
target_residual = x.target_real;
target_residual(x.target_bins) = -Inf;

% source_residual = x.source_real;
% for n = 1:length(x.source_bins)
%     bin = x.source_bins(n);
%     source_residual(bin) = sum(source_residual([bin - 1, bin + 1])) / 2;
% end
% 
% target_residual = x.target_real;
% for n = 1:length(x.target_bins)
%     bin = x.target_bins(n);
%     target_residual(bin) = sum(target_residual([bin - 1, bin + 1])) / 2;
% end

plot([source_residual x.source_real])














