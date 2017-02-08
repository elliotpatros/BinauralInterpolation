%% user parameters
subj = 1006;
dist = 1;

%% load resources
load(['./Resources/IRC_', num2str(subj), '_C_HRIR.mat']);

%% plot
nPositions = length(l_eq_hrir_S.elev_v);
if (length(r_eq_hrir_S.elev_v) ~= nPositions)
    error(['the hrtf library, ', num2str(subj), ' is fubar']);
end

for n = 1:nPositions
    azim = l_eq_hrir_S.azim_v(n);
    elev = l_eq_hrir_S.elev_v(n);
    disp(['n = ', num2str([azim, elev, dist])]);
    [x, y, z] = sph2cart(azim, elev, dist);
    plot3(x, y, z, 'rx');
    hold on;
end

hold off;
