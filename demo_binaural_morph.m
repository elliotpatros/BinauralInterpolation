%% reset
clearvars;
addpath(genpath('.'));

[m, Y1, Y2, Ydb1, Ydb2] = make_fake_session;

%% important things
Ndb = length(Ydb1);
nfft = length(Y1);
nFeatures = length(m(:,1));
nSections = nFeatures - 1;

%% interpolate sections
% weight = 0.5;
for weight = linspace(0, 1, 200)
newYdb = zeros(size(Ydb1));

% get section start index
b1 = 1;
b2 = 1;
newB = round(weighted_mean(b1, b2, weight));

% interpolate first sample in section
newYdb(newB) = weighted_mean(Ydb1(b1), Ydb2(b2), weight);
for section = 1:nSections
    % get section end index
    e1 = m(section+1, 1);
    e2 = m(section+1, 2);
    newE = round(weighted_mean(e1, e2, weight));
    
    % get section length
    scale1 = length(b1:e1) / length(newB:newE);
    scale2 = length(b2:e2) / length(newB:newE);
    
    % interpolate middle samples in section
    for n = newB+1:newE-1
        v1 = cub_int(Ydb1, (n - newB) * scale1 + newB);
        v2 = cub_int(Ydb2, (n - newB) * scale2 + newB);
        newYdb(n) = weighted_mean(v1, v2, weight);
    end
    
    % interpolate end sample in section
    newYdb(newE) = weighted_mean(Ydb1(e1), Ydb2(e2), weight);
    
    % setup section start for next loop
    b1 = e1;
    b2 = e2;
    newB = round(weighted_mean(b1, b2, weight));
end

plot([Ydb1 Ydb2 newYdb]);
drawnow;
end
