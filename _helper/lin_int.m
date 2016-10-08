function y = lin_int(array, position)
%LIN_INT Linear interpolation

n = floor(position);
delta = position - n;
n = n + 1;

y = (1 - delta) * array(n) + delta * array(n + 1);

end

