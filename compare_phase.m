clearvars;
addpath(genpath('.'));

A = -40:5:40;

linx_error = zeros(length(A), 1);
morx_error = zeros(length(A), 1);
linp_error = zeros(length(A), 1);
morp_error = zeros(length(A), 1);

for n = 1:length(A)
    azim = A(n);
[l1,~,fs] = load_binaural(azim-5);
l2 = load_binaural(azim+5);
l3 = load_binaural(azim);
p = unwrap(angle(fft(l3)));

weight = (itd(15) - itd(10)) ./ (itd(20) - itd(10));
% weight = 0.5;
M = find_morphing_surface(l1, l2);

[linx, morphx, linphase, morphphase] = ...
    do_morph_with_surface(l1, l2, M, weight, l3);


linx_error(n) = rms(l3 - linx);
morx_error(n) = rms(l3 - morphx);
linp_error(n) = rms(p  - linphase);
morp_error(n) = rms(p  - morphphase);

end

subplot(211)
plot(A, [linx_error morx_error]);
legend('linear time domain error', 'morphed time domain error');

subplot(212)
plot(A, [linp_error morp_error]);
legend('linear phase error', 'morphed phase error');