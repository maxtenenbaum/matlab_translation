function [y,lowerBound,upperBound,shadeX,shadeY] ...
    = getConfidenceBounds2(data,param,method)
% data is a one-dimensional array of failure time

% Calculate the Z-score for 95% CI
alpha = 0.05;
pValue = 1 - alpha;
% pValue_ = 1 - alpha / 2;
% zScore = norminv(pValue);

% Data Points
prob_arr = getMedianRank(data,method,false);
probPlot_arr = getTransform(prob_arr);
n = length(data);

% Fit Weibull distribution using MLE
scale_a = param(1);
shape_b = param(2);

% Weibull CDF
line = wblcdf(data, scale_a, shape_b);
y = getTransform(line); % y-values for Weibull fit plotting

% Confidence Bounds for Weibull CDF
% lowerBound = wblcdf(x, scale_a_ci_lower, shape_b);
% upperBound = wblcdf(x, scale_a_ci_upper, shape_b);

% Confidence Bounds for Beta CDF
% lowerBound = zeros(n,1);
% upperBound = zeros(n,1);
idx_arr = transpose(1:n);
beta_a = idx_arr;
beta_b = n + 1 - idx_arr;
lowerBound_raw = betainv(pValue, beta_a, beta_b);
upperBound_raw = betainv(alpha, beta_a, beta_b);
%(-log(1-upperBound_raw))
lowerBound = scale_a * exp(getTransform(lowerBound_raw)) .^ (1/shape_b);
upperBound = scale_a * exp(getTransform(upperBound_raw)) .^ (1/shape_b);

% Data for Shaded Area in Plot
shadeX = [upperBound;flip(lowerBound)];
shadeY = [probPlot_arr;flip(probPlot_arr)];

end