clearvars;
addpath(genpath('.'));


%% solve weight given 
    % DOA interval (k), 
    % DOA,
    % head-distance (d), 
    % and sound speed (c)

c = 340;        % meters per second
d = 0.215;      % meters
k = 15;         % degrees

test_interval = 1;
DOA = 0:test_interval:360;
weight = zeros(size(DOA));

for n = 1:length(DOA)
    % linear
%     weight(n) = mod(DOA(n) / k, 1);
    % ITD
    maxITD = d/c;
    d_L = (d/2)
end

plot(DOA, weight)
