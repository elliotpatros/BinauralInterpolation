function y = cub_int(array, position)

%% do input error checking
L = length(array);
if L < 4
%     error('length of array must be greater than 4');
    temp = zeros(4, 1);
    scale = L / 4;
    for n = 1:L
        temp(n) = lin_int(array, n * scale);
    end
    L = 4;
    array = temp;
    clear temp;
end

%% make index 0
I = zeros(4, 1);
I(2) = floor(position);
dec = position - I(2);

%% make indexes
I(1) = I(2) - 1;
I(3) = I(2) + 1;
I(4) = I(2) + 2;

I(I<1) = 1;
I(I>L) = L;

%% lookup values
X = array(I);
a = (3*(X(2)-X(3))-X(1)+X(4))/2;
b = 2*X(3)+X(1)-(5*X(2)+X(4))/2;
c = (X(3)-X(1))/2;

%% solve
y = (((a*dec)+b)*dec+c)*dec+X(2);


end

