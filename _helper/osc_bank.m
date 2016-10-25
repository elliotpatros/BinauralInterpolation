function y = osc_bank(mag, phase, fs)

% get lengths of mag and phase vectors
Lmag = length(mag);
Lpha = length(phase);
if Lmag ~= Lpha
    error('length of mag and phase must be the same');
end

% preprocess oscillator bank
mag = mag ./ Lmag;      % normalize magnitudes
nT = (0:Lmag-1)'./fs;   % setup oscillator phase
y = zeros(Lmag, 1);     % zero out time domain signal

% for each frequency and phase, add an oscillator
for n = 1:Lmag
    freq = bin_to_freq(n, fs, Lmag);
    y = y + mag(n) .* cos(2.*pi.*freq.*nT + phase(n));
end

end

