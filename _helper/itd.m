function t = itd(theta)

c = 343;
d = 0.215;
t = d .* abs(sin(deg2rad(theta))) ./ c;

end

