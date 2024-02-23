function stat_matrix = getStat(data_arr,dist_arr)
%% Variables
stat_matrix = {};

%% Function
if contains(dist_arr,'norm','IgnoreCase',true)
    fprintf('Retrieving normal distribution statistics...');
    avg = mean(data_arr,'all');
    sd = std(data_arr,0,'all');
    stat = [avg sd];
    stat_matrix_alloc = [stat_matrix,stat];
    stat_matrix = stat_matrix_alloc;
    fprintf('OK.\n');
end

if contains(dist_arr,'logn','IgnoreCase',true)
    fprintf('Retrieving lognormal distribution statistics...');
    logParam = lognfit(data_arr);
    expectedLogMean = logParam(1);
    expectedLogSD = logParam(2);
    [logMean,logSD] = lognstat(expectedLogMean,expectedLogSD);
    stat = [logMean logSD];
    stat_matrix_alloc = [stat_matrix,stat];
    stat_matrix = stat_matrix_alloc;
    fprintf('OK.\n');
end

if contains(dist_arr,'weibull','IgnoreCase',true)
    fprintf('Retrieving Weibull distribution statistics...');
    weibullParam = wblfit(data_arr);
    scale = weibullParam(1);
    shape = weibullParam(2);
    [weibullMean,weibullSD] = weblstat(scale,shape);
    stat = [weibullMean weibullSD];
    stat_matrix_alloc = [stat_matrix,stat];
    stat_matrix = stat_matrix_alloc;
    fprintf('OK.\n');
end

end