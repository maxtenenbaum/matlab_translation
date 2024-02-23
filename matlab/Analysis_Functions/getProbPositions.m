function probPositions_arr = getProbPositions(data)

n = length(data);
idx_arr = transpose(1:n);
probPositions_arr = (idx_arr - 0.5) / n;

end