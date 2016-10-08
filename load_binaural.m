function [left, right, fs] = load_binaural(azimuth, elevation)
%LOAD_BINAURAL loads one binaural impulse response

load HRIR.mat hrir_l hrir_r;

% get closest azimuth
azimuths = [-80 -65 -55 -45:5:45 55 65 80];
[~, az] = min(abs(azimuths - azimuth));

% get closest elevation
elevations = -45 + 5.625 * (0:49);
[~, el] = min(abs(elevations - elevation));

% get the sound files
left = squeeze(hrir_l(az, el, :));
right = squeeze(hrir_r(az, el, :));

fs = 44100;

end

