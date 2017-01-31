clear all;
addpath(genpath('.'));

azims = -40:5:40;
weight = 0.5;

for n = 1:length(azims)
    this = azims(n);
    prev = this-5;
    next = this+5;
    l1 = load_binaural(prev);
    l2 = load_binaural(next);
    ltruth = load_binaural(this);
    
    M = find_morphing_surface(l1, l2);
    lderived = do_morph_with_surface(l1, l2, M, weight);

    
    subplot(211);
    plot([ltruth, lderived]);
    subplot(212);
    plot(ltruth - lderived);
    drawnow;
    disp(['guessing ', ...
          num2str(this), ...
          ' by morphing between ', ...
          num2str(prev), ...
          ' and ', ...
          num2str(next)]);
    pause;
end