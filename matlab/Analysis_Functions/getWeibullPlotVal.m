function [data_sort,data_prob,a,b,bounds] = getWeibullPlotVal(data)
%% Variables
data_count = numel(data);
data_prob = zeros(1,data_count);
data_sort = sort(data);

%% Function
for idx = 1:data_count
    data_prob(idx) = (idx - 0.5) / data_count;
end

[param,~] = wblfit(data);
a = param(1);
b = param(2);

weibullFitting = fittype('weibull');
weibullCurve = cfit(weibullFitting,a,b);
bounds = predint(weibullCurve,data,0.9,'observation','on');

end