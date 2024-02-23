function fig = wblplot2(data)
%% Constants
PROB_AXIS = [0.001,0.01,0.02,0.05,0.10,0.25,0.50,0.75,0.90,0.99,0.999];

%% Variables
fig = gcf;
len = length(PROB_AXIS);

%% Sort
data_sort = sort(data);
numOfSamples = length(data_sort);
idx = 1:numOfSamples;
prob = (idx - 0.5) / numOfSamples;
prob_fix = getProbPlot(prob);
prob_min = min(prob);
prob_max = max(prob);

%% Limits
% lower
if prob_min < PROB_AXIS(2)
    prob_axis_min_idx = 1;
    prob_axis_min = PROB_AXIS(prob_axis_min_idx);
else
    prob_axis_min_idx = 2;
    prob_axis_min = PROB_AXIS(prob_axis_min_idx);
end
% upper
if prob_max > PROB_AXIS(len-1)
    prob_axis_max_idx = len;
    prob_axis_max = PROB_AXIS(prob_axis_max_idx);
else
    prob_axis_max_idx = len - 1;
    prob_axis_max = PROB_AXIS(prob_axis_max_idx);
end
% axis
prob_axis_new = PROB_AXIS(prob_axis_min_idx:prob_axis_max_idx);
prob_axis_fix = getProbPlot(prob_axis_new);
yLimits = [prob_axis_min prob_axis_max];
yLimits_fix = getProbPlot(yLimits);

%% Plot
plot(data_sort,prob_fix, ...
    'Marker','+', ...
    'LineStyle','none');
ax = gca;
ax.XScale = 'log';
ax.YScale = 'log';
ax.YTick = prob_axis_fix;
ax.YMinorTick = 'off';
ax.YTickLabel = string(prob_axis_new);
ylim(yLimits_fix);

end