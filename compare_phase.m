clearvars;
addpath(genpath('.'));

[l1,~,fs] = load_binaural(10);
l2 = load_binaural(20);
l3 = load_binaural(15);

weight = 0.5;
M = find_morphing_surface(l1, l2);
new_l = do_morph_with_surface(l1, l2, M, weight, l3);

% ph_hat = weighted_mean(Yph1, Yph2, 0.5);
% 
% subplot(311)
% plot([Yph1 Yph2 Yph3 ph_hat])
% legend('phase - 1', 'phase - 2', 'middle phase', 'derived phase');
% 
% subplot(312)
% plot([Yph3 ph_hat])
% legend('middle phase', 'derived phase')
% 
% subplot(313)
% plot(Yph3 - ph_hat)
% legend('error')