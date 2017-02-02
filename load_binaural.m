function [LHS, RHS, fs] = load_binaural(azim, elev, subj)

if nargin < 3
    subj = 1006;
end
if nargin < 2
    elev = 0;
end

filename = ['./Resources/IRC_', num2str(subj), '_C_HRIR.mat'];
load(filename);

azim = mod(azim, 360);

index = 1;
while l_eq_hrir_S.elev_v(index) ~= elev
    index = index + 1;
end

% disp(['elevation ', num2str(elev), ' is at index ', num2str(index)]);

while l_eq_hrir_S.azim_v(index) ~= azim
    index = index + 1;
end

% disp(['azimuth ', num2str(azim), ' is at index ', num2str(index)]);

LHS = l_eq_hrir_S.content_m(index, :)';
RHS = r_eq_hrir_S.content_m(index, :)';
fs = l_eq_hrir_S.sampling_hz;

end

