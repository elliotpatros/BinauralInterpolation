function t = itd(azim)

c = 343;
d = 0.215;
t = d * abs(sin(azim)) ./ c;

end

