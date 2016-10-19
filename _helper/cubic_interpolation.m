function y = cubic_interpolation(array, position)

L = length(array);

% make index 0
I = floor(position);
D = position - I;

if L < 2
    y = array(1);
elseif L < 4
    y = lin_int(array, position);
else
% lookup values
Xm = array(min(max(I - 1, 1), L));
X0 = array(min(max(I + 0, 1), L));
X1 = array(min(max(I + 1, 1), L));
X2 = array(min(max(I + 2, 1), L));

% solve
a = (3 .* (X0 - X1) - Xm + X2) ./ 2;
b = 2 .* X1 + Xm - (5 .* X0 + X2) ./ 2;
c = (X1 - Xm) ./ 2;
y = (((a .* D) + b) .* D + c) .* D + X0;
end
    
end

