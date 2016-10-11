function newpeak = morph_peak(source, target, weight)

% make both peaks the same size
% crossfade corresponding samples

Ls = length(source);
Lt = length(target);

Ln = round((1-weight)*Ls + weight*Lt);
newpeak = zeros(Ln, 1);

stretch = Ln / Ls;
for n = 1:Ln;
    newpeak(n) = newpeak(n) + lin_int(source, n * stretch - 1);
end

stretch = Ln / Lt;
for n = 1:Ln;
    newpeak(n) = newpeak(n) + lin_int(target, n * stretch - 1);
end

end

