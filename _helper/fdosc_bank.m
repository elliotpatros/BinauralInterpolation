function y = fdosc_bank(mag, phase)

% get lengths of mag and phase vectors
L = length(mag);
if L ~= length(phase)
    error('length of mag and phase must be the same');
end

nT = 0:L-1;
y = sum((mag/L) .* cos(2*pi .* (nT/L) .* nT' + phase))';

end

