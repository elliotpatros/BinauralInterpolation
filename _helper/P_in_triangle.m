function answer = P_in_triangle(P, A, B, C)

alpha = ((B(2) - C(2)) * (P(1) - C(1)) + (C(1) - B(1)) * (P(2) - C(2))) / ((B(2) - C(2)) * (A(1) - C(1)) + (C(1) - B(1)) * (A(2) - C(2)));
beta = ((C(2) - A(2)) * (P(1) - C(1)) + (A(1) - C(1)) * (P(2) - C(2))) / ((B(2) - C(2)) * (A(1) - C(1)) + (C(1) - B(1)) * (A(2) - C(2)));
gamma = 1 - alpha - beta;

answer = alpha >= 0 && beta >= 0 && gamma >= 0;

end

