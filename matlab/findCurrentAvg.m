function [...
    runCTExp,...
    isBufferFull,...
    bufferMatrix,...
    structExclude,...
    slopeArray,...
    interceptArray,...
    currentAvg]...
    = findCurrentAvg(...
    runCTExp,...
    bufferLength,...
    numOfStdDev,...
    channelSelect_len,...
    channelNameList,...
    samplingPeriod,...
    sampleNum,...
    currentArray,...
    bufferMatrix,...
    slopeArray,...
    interceptArray,...
    structExclude,...
    isBufferFull)
%% Constants
% Values
LINREG_SLOPE_IDX = 1;       % index for slope in polyfit
LINREG_INTERCEPT_IDX = 2;   % index for y-intercept in polyfit
% ROWS_IDX = 2;
FIRST = 1;
ONE = 1;
% Matrices
TABLE_HEADING = {...
    'Channel',...
    'Current (A)',...
    'Mean (A)',...
    '+/-SD (A)'};

%% Variables
dataArray = zeros(channelSelect_len,ONE);
% regressionArray = zeros(channelSelect_len,ONE);
averageArray = zeros(channelSelect_len,ONE);
stdDevArray = zeros(channelSelect_len,ONE);
sampleTime = (sampleNum - ONE) * samplingPeriod;

%% Function
% Add data point to buffer
bufferMatrix(:,sampleNum) = currentArray;

% Check updated buffer
for channel_idx = FIRST:channelSelect_len
    dataArray(channel_idx) = currentArray(channel_idx);
    bufferArray = bufferMatrix(channel_idx,:);
    sampleArray = FIRST:sampleNum;
    timeArray = (sampleArray - ONE) * samplingPeriod;
    
    % Average
    average = mean(bufferArray);
    stdDev = std(bufferArray);
    acceptable = numOfStdDev * stdDev;
    maxAcceptable = average + acceptable;
    minAcceptable = average - acceptable;
    tooHigh = find(bufferArray > maxAcceptable);
    tooLow = find(bufferArray < minAcceptable);
    exclude_idx_raw = [tooHigh,tooLow];
    exclude_idx = sort(exclude_idx_raw);
    structExclude(channel_idx).Index = exclude_idx;
    structExclude(channel_idx).Time = timeArray(exclude_idx);
    structExclude(channel_idx).Current = bufferArray(exclude_idx);
    if ~isempty(exclude_idx)
        bufferArray(exclude_idx) = [];
        timeArray(exclude_idx) = [];
        average = mean(bufferArray);
        stdDev = std(bufferArray);
    end
    
    % Linear regression
    % trendline
    linReg = polyfit(timeArray,bufferArray,FIRST);
    slope = linReg(LINREG_SLOPE_IDX);
    intercept = linReg(LINREG_INTERCEPT_IDX);
    slopeArray(channel_idx) = slope;
    interceptArray(channel_idx) = intercept;
    averageArray(channel_idx) = average;
    stdDevArray(channel_idx) = stdDev;
end

% Print table
fullTable = table(...
    channelNameList,...
    dataArray,...
    averageArray,...
    stdDevArray,...
    'VariableNames',TABLE_HEADING);
fprintf('Samples: N = %d\n',sampleNum);
fprintf('Sample Time: t = %.2f s\n',sampleTime);
fprintf('Buffer Length: n = %g\n',bufferLength);
fprintf('Acceptable Standard Deviation: +/-%g SD\n',numOfStdDev);
disp(fullTable);

currentAvg = averageArray;

end