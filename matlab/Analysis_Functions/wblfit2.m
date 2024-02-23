function [parmHat,parmCI] = wblfit2(data,method,getUnique)
%% Constants
ALPHA = 0.05;
NUM_OF_BOOTSTRAP = 1e3;

%% Variables
if getUnique
    data = unique(data);
end
x = log(data);

%% Median Rank
rank_arr = getMedianRank(data,method,getUnique);

%% Parameters
y = getTransform(rank_arr);
[slope,intercept,~] = getLinReg2(x,y,'mle');
b = slope;
a = exp(-intercept / b);
parmHat = [a b];

%% Confidence Interval
% Initialize arrays for bootstrap estimates
a_values = zeros(NUM_OF_BOOTSTRAP,1);
b_values = zeros(NUM_OF_BOOTSTRAP,1);

for idx = 1:NUM_OF_BOOTSTRAP
    % Resample data with replacement
    data_sample = data(randi(length(data), length(data), 1));
    x_sample = log(data_sample);
    rank_sample = getMedianRank(data_sample,method,getUnique);
    y_sample = getTransform(rank_sample);

    % Estimate parameters for resampled data
    [slope,intercept,~] = getLinReg2(x_sample,y_sample,'mle');
    b_sample = slope;
    a_sample = exp(-intercept / b);

    % Store estimates
    a_values(idx) = a_sample;
    b_values(idx) = b_sample;
end

% Calculate confidence intervals
alpha2 = ALPHA / 2;
a_CI = quantile(a_values, [alpha2;1-alpha2]);
b_CI = quantile(b_values, [alpha2;1-alpha2]);
parmCI = [a_CI b_CI];

end