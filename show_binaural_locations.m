%% user parameters
subj = 1006;
radius = 1;

%% load resources
load(['./Resources/IRC_', num2str(subj), '_C_HRIR.mat']);

%% plot
nPositions = length(l_eq_hrir_S.elev_v);
if (length(r_eq_hrir_S.elev_v) ~= nPositions)
    error(['the hrtf library, ', num2str(subj), ' is fubar']);
end

azim = deg2rad(l_eq_hrir_S.azim_v);
elev = deg2rad(l_eq_hrir_S.elev_v);
dist = ones(size(azim)) .* radius;

plot3(0, 0, 0, 'bo');
grid on;
hold on;

[x,y,z] = sph2cart(azim, elev, dist);
plot3(x, y, z, 'ro');
hold off;
