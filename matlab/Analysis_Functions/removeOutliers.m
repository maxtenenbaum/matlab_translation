function [data,outlier_idx] = removeOutliers(data)

fprintf('Removing outliers...');
startTime = tic;
normOutlier_idx = isoutlier(data,'median');
logData = log10(data);
logOutlier_idx = isoutlier(logData,'median');
outlier_idx = or(normOutlier_idx,logOutlier_idx);

data(outlier_idx) = [];
ftOutlier_count = nnz(outlier_idx);
[endTime,unit] = getEndTime(startTime);
fprintf('%d (%.2f %s)\n',ftOutlier_count,endTime,unit);

end