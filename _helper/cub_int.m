function y = cub_int(array, position)

L = length(array);
if L < 2
    % do input error checking
    y = array(1);
elseif L < 4
    % do linear interpolation if array is too small for cubic
    y = lin_int(array, position);
else
    % make index 0
    I = floor(position);
    D = position - I;

    % lookup values
    X = array(min(max([I-1, I, I+1, I+2], 1), L));
    a = (3 * (X(2) - X(3)) - X(1) + X(4)) / 2;
    b = 2 * X(3) + X(1) - (5 * X(2) + X(4)) / 2;
    c = (X(3) - X(1)) / 2;
    
    % solve
    y = (((a * D) + b) * D + c) * D + X(2);
end

end

