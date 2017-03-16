clearvars;
addpath(genpath('.'));

% show left channel HRIRs for front arc

A = -45:5:45;
for n = 1:length(A)
    azim = A(n);
    signal = load_binaural(azim);
    
    x = 1:length(signal);
    y = ones(1, length(signal)) .* azim;
    z = signal;
    
    plot3(x, y, z);
    hold on;
end
hold off;
