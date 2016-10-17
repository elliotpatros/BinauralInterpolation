%% reset
clearvars;
addpath(genpath('.'));

[m, Y1, Y2, Ydb1, Ydb2] = make_fake_session;
Ndb = length(Ydb1);
nfft = length(Y1);

%% interpolate sections
weight = 0.25;
newYdb = zeros(size(Ydb1));


