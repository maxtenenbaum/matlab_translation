function [x,line,lower,upper,shade_x,shade_y] = getConfidenceBounds(data,phat,ci,numOfValues)

method = 'delta';

% Calculate the Z-score for 95% CI
alpha = 0.05;
pValue = 1 - alpha / 2;
zScore = norminv(pValue);

% Data Points
data_min = min(data);
data_max = max(data);
% data_min_log = log10(data_min);
% data_max_log = log10(data_max);
% x = logspace(data_min_log,data_max_log,numOfValues);
x = linspace(data_min,data_max,numOfValues);
% x = data;
n = length(data);
% data_fix = zeros(n,1);
% data_fix(:) = data(:);
% data = data_fix;

% Fit Weibull distribution using MLE
if isempty(phat) || isempty(ci)
    [phat,ci] = wblfit(data);
end
scale_a = phat(1);
shape_b = phat(2);
scale_a_ci = ci(:,1);
shape_b_ci = ci(:,2);
% [wbl_mean,wbl_var] = wblstat(scale_a,shape_b);
% wbl_sd = sqrt(wbl_var);

% Confience Bound Methods
switch method
    case 'fisher'
        % Fisher Matrix-based approach for larger samples
        % Calculate the standard errors
        scale_SE = (scale_a_ci(2) - scale_a_ci(1)) / (2 * zScore);
        shape_SE = (shape_b_ci(2) - shape_b_ci(1)) / (2 * zScore);

        % Calculate the confidence intervals
        scale_CI = scale_a + zScore * scale_SE * [-1 1];
        shape_CI = shape_b + zScore * shape_SE * [-1 1];
    case {'beta','binomal','beta binomial','beta-binomial','bb'}
        % Beta-binomial approach for smaller samples
        % prob_positions = ((1:n) - 0.5) / n;
        scale_CI_bounds = zeros(n, 2);
        shape_CI_bounds = zeros(n, 2);
        for i = 1:n
            a = i;
            b = n - i + 1;
            lower_bound = betainv(1-pValue, a, b);
            upper_bound = betainv(pValue, a, b);

            % Convert beta bounds to Weibull scale for each data point
            scale_CI_bounds(i, :) = wblinv([lower_bound upper_bound], scale_a, shape_b);
            shape_CI_bounds(i, :) = wblinv([lower_bound upper_bound], scale_a, shape_b); % Note: shape parameter bounds need a different approach
        end
        % Aggregate the bounds
        scale_CI = [min(scale_CI_bounds(:,1)), max(scale_CI_bounds(:,2))];
        shape_CI = [min(shape_CI_bounds(:,1)), max(shape_CI_bounds(:,2))];
end

% Bounds
line = wblcdf(x, scale_a, shape_b);
switch method
    case 'delta'
        % Calculate the standard errors
        scale_SE = (scale_a_ci(2) - scale_a_ci(1)) / (2 * zScore);
        shape_SE = (shape_b_ci(2) - shape_b_ci(1)) / (2 * zScore);
        var_line = (x.^shape_b .* exp(-x.^shape_b / scale_a) .* (shape_b / scale_a).^2 .* scale_SE.^2) + ...
            (x.^shape_b .* exp(-x.^shape_b / scale_a) .* log(x / scale_a).^2 .* shape_SE.^2);
        % Calculate Confidence Bands
        sd_line = sqrt(var_line);
        lower = line - zScore * sd_line;
        upper = line + zScore * sd_line;
    otherwise
        lower = wblcdf(x, scale_CI(1), shape_CI(1));
        upper = wblcdf(x, scale_CI(2), shape_CI(2));
end
% Adjustments to ensure bounds are logical
lower(lower < 0) = 0; % Ensure lower bound is not less than 0
upper(upper <= 0) = min(line(line > 0)); % Ensure upper bound is not zero or negative

% Data for Shaded Area in Plot
shade_x = [x, fliplr(x)];
shade_y = [upper, fliplr(lower)];

% Output Formatting
x = x';
line = line';
lower = lower';
upper = upper';
shade_x = shade_x';
shade_y = shade_y';

end