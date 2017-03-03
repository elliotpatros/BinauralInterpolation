%% show that ITD can be approximated by abs(sin(DOA).*d.*c
% DOA interval (k), 
% DOA,
% head-distance (d), 
% and sound speed (c)

clearvars;

c = 340;        % meters per second
d = 0.215;      % meters

DOA = deg2rad(0:360);
ITD_truth = get_itd(DOA, d, c);
ITD_approx = abs(sin(DOA)) .* (d/c);

subplot(211);
plot(DOA, ITD_truth, DOA, ITD_approx);
subplot(212);
plot(DOA, ITD_truth - ITD_approx);
