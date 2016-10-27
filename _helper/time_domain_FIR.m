function y = time_domain_FIR(x, fir)

Lf = length(fir);
Lx = length(x);

y = zeros(size(x));

for n = 1:Lx
	for k = 1:min(Lf, n)
        bk = fir(k);
        xn = x(n - (k - 1));
        y(n) = y(n) + bk * xn;
	end
end

end