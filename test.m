%% reset
clearvars;
[m, Y1, Y2, Ydb1, Ydb2] = make_fake_session;
Ndb = length(Ydb1);
nfft = length(Y1);

%% interpolate sections
newYdb = zeros(size(Ydb1));

section = 1;
newYdb(1) = weighted_mean(Ydb1(1), Ydb2(1), weight);
for section = 2:length(m(:,1))


% %% find out where section barriers are
% weight = 0.1;
% % for weight = linspace(0, 1, 100)
% section_edges = zeros(length(m), 1);
% 
% for n = 1:length(m);
%     section_edges(n) = round(weighted_mean(m(n,2), m(n,1), weight));
% end
% 
% plot(section_edges, ones(size(section_edges))*weight, 'ko'); hold on;
% for n = 1:length(m)
%     plot(m(n,:), [1 0], 'k:o');
% end
% drawnow;
% hold off;
% % end