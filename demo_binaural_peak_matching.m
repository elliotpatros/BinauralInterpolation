clearvars;
addpath(genpath('.'));

%% user input
az1 = 5;
el1 = 0;
az2 = 15;
el2 = 0;
weight = 0.5;
minDist = 3;

%% get audio
[x1, ~, fs] = load_binaural(az1, el1);
x2 = load_binaural(az2, el2);

%% pick and peaks
Y1 = do_fft(x1, false);             % spectrum
p1 = get_peak_bins(Y1, -Inf);       % peak bins
s1 = sort_loudest_peaks(Y1, p1);    % sorted bins (loudest first)
l1 = length(p1);                    % length of p1

Y2 = do_fft(x2, false);             % spectrum
p2 = get_peak_bins(Y2, -Inf);       % peak bins
s2 = sort_loudest_peaks(Y2, p2);    % sorted bins (loudest first)
l2 = length(p2);                    % length of p2

%% nearest neighbor assignment
maxNumPeaks = max(l1, l2);
if l2 < maxNumPeaks
    source = s1;
    target = s2;
    sY = Y1;
    tY = Y2;
    longer = 1;
else
    source = s2;
    target = s1;
    sY = Y2;
    tY = Y1;
    longer = 2;
end

m = zeros(maxNumPeaks, 1);
for n = 1:maxNumPeaks
    [~, c] = min(abs(target - source(n)));
    if abs(source(n) - target(c)) < minDist
        m(n) = c;
    end
end

%% plot results
for n = 1:maxNumPeaks
    % plot all peaks from both signals
    clf; plot([Y1 Y2]); hold on;
    plot(p1, Y1(p1), 'v', p2, Y2(p2), 'v');

    % plot matches
    if m(n) ~= 0
        haxis = [source(n), target(m(n))];
    else
        haxis = [source(n), source(n)];
    end

    vaxis = [sY(haxis(1)), tY(haxis(2))];
    plot(haxis, vaxis, 'or', 'MarkerSize', 10);
    drawnow;
    pause;
end
