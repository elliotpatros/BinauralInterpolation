c = 340;
d = 0.215;
k = 15;
doa = 0:k:360;

phi = 0:360;
lin_weight = zeros(size(0:360));
itd_weight = zeros(size(lin_weight));

for n = 1:length(phi)
    prev = floor(phi(n) / k) * k;
    next = ceil((phi(n) + 1) / k) * k;
    
    prev_itd = sin(deg2rad(prev)) * d / c;
    next_itd = sin(deg2rad(next)) * d / c;
    this_itd = sin(deg2rad(phi(n))) * d / c;
    
    lin_weight(n) = (phi(n) - prev) / (next - prev);
    itd_weight(n) = (this_itd - prev_itd) / (next_itd - prev_itd);
end

plot(phi, lin_weight, 'bo-', phi, itd_weight, 'ro-');
legend('linear', 'ITD');
