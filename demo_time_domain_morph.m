%% reset
clearvars;
addpath(genpath('.'));

%% user parameters
azim1 = 50;
azim2 = 55;

nFrames = 150;

%% load audio
% get HRIR's
l1 = load_binaural(azim1, 0);
l2 = load_binaural(azim2, 0);
Lhrir = length(l1);

%% morph
pausefor = 0.5;
clf; pause;
while true
for n = [1:nFrames, nFrames-1:-1:1]
    weight = (n - 1) / (nFrames - 1);   % weight from 0 to 1 over nFrames
    
    new_l = do_morph(l1, l2, weight);
    
    plot([l1 new_l l2]);
%     axis([1 Lhrir -0.5 0.5]);
    drawnow;
    if n == nFrames
        pause(pausefor);
    end
end

pause(pausefor);
end

