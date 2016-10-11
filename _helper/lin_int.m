function y = lin_int(array, position)
%LIN_INT Linear interpolation

n = floor(position);
delta = position - n;

lhs = array(max(n, 1));
rhs = array(min(n + 1, length(array)));

y = (1 - delta) * lhs + delta * rhs;

end

