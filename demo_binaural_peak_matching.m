clearvars;
addpath(genpath('.'));

%% user input
az1 = 5;
el1 = 0;
az2 = 15;
el2 = 0;
weight = 0.5;
minDist = 3;
shouldplot = true;

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
minNumPeaks = min(l1, l2);
maxNumPeaks = max(l1, l2);
m1 = zeros(l1, 1);
m2 = zeros(l2, 1);                  % matched bin indexes
for n = 1:l1
    % find nearest peak
    [~, c] = min(abs(s2 - s1(n)));
    if abs(s1(n) - s2(c)) < minDist
        m2(n) = c;
    end
end
for n = 1:l2
    % find nearest peak
    [~, c] = min(abs(s1 - s2(n)));
    if abs(s2(n) - s1(c)) < minDist
        m1(n) = c;
    end
end

% plot progress
if shouldplot
    for n = 1:maxNumPeaks
        % plot all peaks from both signals
        clf; plot([Y1 Y2]); hold on;
        plot(p1, Y1(p1), 'v', p2, Y2(p2), 'v');
        
        % plot matches
        if n <= l1
            if m1(n) ~= 0
                haxis = [s1(m1(n)), s2(n)]; disp('A');
            else
                haxis = [s1(n), s1(n)]; disp('C');
            end
        else
            if m2(n) ~= 0
                haxis = [s1(n), s2(m2(n))]; disp('B');
            else
                haxis = [s2(n), s2(n)]; disp('C');
            end
        end
        
        vaxis = [Y1(haxis(1)), Y2(haxis(2))];
        plot(haxis, vaxis, 'or', 'MarkerSize', 10);
        drawnow;
        pause;
    end
end

