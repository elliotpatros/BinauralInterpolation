clearvars;
addpath(genpath('.'));

% plot out how all the phases look together in 3D
% right now, this plot takes a look at the 1st derivative of phase from
% bin0 to nyquist

azims = -45:5:45;
x = load_binaural(0);

nAzims = 3; %length(azims);
L = length(x);

% phases = zeros(nAzims, L);

for n = 1:nAzims
    azim = azims(n);
    x = load_binaural(azims(n));

    phase = unwrap(angle(fft(x)));
    phase = phase(1:end/2 + 1);
    %     phases(n,:) = unwrap(angle(fft(x)));
    
    nFreqs = length(phase) - 1;
    
    plot3(ones(nFreqs, 1) .* azim, 1:nFreqs, diff(phase));
    hold on
end

hold off;

% 
% nT = 1:length(azims);
% 
% freqs = 1:L;
% plot(freqs, nT, phases)