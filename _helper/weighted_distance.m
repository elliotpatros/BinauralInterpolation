function D = weighted_distance(pos1, pos2, weight)

D = sqrt(sum(((pos2 - pos1).*weight).^2));

end

