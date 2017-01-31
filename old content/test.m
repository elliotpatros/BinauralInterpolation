%% reset
clearvars;
addpath(genpath('.'));

nFrames = 1000;
directions = linspace(0, 2*pi, nFrames) + pi/2;

headradius = 0.075;  % meters
sourcedist = headradius;   % meters
ears = [-headradius, headradius; ...    % xl, xr
        0, 0];                          % yl, yr

soundspeed = 340; % m/sec
delays = zeros(nFrames, 2);

% top down view of source and ears
for n = 1:nFrames
    % find source position from angle and distance
    theta = directions(n);
    [sourcex, sourcey] = pol2cart(theta, sourcedist);
    
    delays(n, 1) = distance2D(ears(:,1), [sourcex, sourcey]') / soundspeed;
    delays(n, 2) = distance2D(ears(:,2), [sourcex, sourcey]') / soundspeed;
    ITD = abs(diff(delays, 1, 2));
    
    subplot(211);
    plot(ears(1,:), ears(2,:), 'x'); hold on;   % plot ear locations
    plot(sourcex, sourcey, 'o');                % plot source location
    plot([ears(1,1), sourcex], [ears(2,1), sourcey], 'k-', ...
         [ears(1,2), sourcex], [ears(2,2), sourcey], 'k-');
    hold off;
    axis([-1 1 -1 1].*sourcedist);
    
    subplot(212);
    plot(directions-pi/2, delays); hold on;
    plot(directions-pi/2, ITD);
    plot(0:pi/2:2*pi, [0, 1, 0, 1, 0].*4.4118e-04);
    hold off;
    
    drawnow;
end
