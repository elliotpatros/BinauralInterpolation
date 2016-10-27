function y = fdosc_bank(mag, phase)

% get lengths of mag and phase vectors
if size(mag) ~= size(phase)
    error('vectors MAG and PHASE must be the same size');
end

L = length(mag);
nT = (0:(L - 1))';

y = zeros(L, 1);
for n = 1:L
    gain = mag(n) / L;
    freq = 2 * pi * (n - 1) / L;
    y = y + gain .* cos(freq .* nT + phase(n));
end

end

