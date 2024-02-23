function prob = getProb(probPlot_val)

prob = -(exp(-exp(probPlot_val)) - 1);

end