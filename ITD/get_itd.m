function itd = get_itd(doa, headsize, soundspeed)

a = 1; % center of head to soundsource
b = headsize./2; % center of head to ear

l_angle = wrapTo2Pi(pi/2 + doa);
r_angle = wrapTo2Pi(pi/2 - doa);

l_dist = sqrt(a.^2 + b.^2 - 2.*a.*b .* cos(l_angle));
r_dist = sqrt(a.^2 + b.^2 - 2.*a.*b .* cos(r_angle));

l_time = l_dist ./ soundspeed;
r_time = r_dist ./ soundspeed;

itd = abs(l_time - r_time);

end

