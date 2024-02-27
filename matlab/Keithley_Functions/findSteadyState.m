function [...
    runCTExp,...
    isBufferFull,...
    bufferMatrix,...
    structExclude,...
    slopeArray,...
    interceptArray,...
    steadyState,...
    isSteadyStateFound]...
    = findSteadyState(...
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
        isBufferFull,...
        steadyState)
%% Constants
% Values
LINREG_SLOPE_IDX = 1;       % index for slope in polyfit
LINREG_INTERCEPT_IDX = 2;   % index for y-intercept in polyfit
% ROWS_IDX = 2;
STEADY_STATE_MAG = 3;
STEADY_STATE_COEFF = 1;
% Matrices
TABLE_HEADING = {...
    'Channel',...
    '|Steady State Slope| (A/n)',...
    'Steady State (A)',...
    'Current (A)',...
    'Slope (A/n)',...
    'Mean (A)',...
    '+/-SD (A)'};
% ,...
%     'Mean-Intercept Difference (%)'
%% Variables
steadyStateSlope = zeros(channelSelect_len,1);
dataArray = zeros(channelSelect_len,1);
regressionArray = zeros(channelSelect_len,1);
averageArray = zeros(channelSelect_len,1);
stdDevArray = zeros(channelSelect_len,1);
percentDiffArray = zeros(channelSelect_len,1);
steadyStateArray = strings(channelSelect_len,1);
sampleTime = (sampleNum - 1) * samplingPeriod;
isSteadyStateFound = 0;

%% Function
% Add data point to buffer
if isBufferFull == false
    bufferMatrix(:,sampleNum) = currentArray;
else
    bufferMatrix(:,end) = currentArray;
end

% Check updated buffer
[~,bufferLength_now] = size(bufferMatrix);
for channel_idx = 1:channelSelect_len
    dataArray(channel_idx) = currentArray(channel_idx);
    bufferArray = bufferMatrix(channel_idx,:);
    if sampleNum >= bufferLength
        start = sampleNum - bufferLength + 1;
        sampleArray = start:sampleNum;
    else
        sampleArray = 1:sampleNum;
    end
    timeArray = (sampleArray - 1) * samplingPeriod;
    
    % Average
    average = mean(bufferArray);
    partBufferLength = bufferLength * 0.1;
    latestCurrent = bufferArray(bufferLength-partBufferLength:end);
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
    linReg = polyfit(timeArray,bufferArray,1);
    slope = linReg(LINREG_SLOPE_IDX);
    slope_mag = abs(slope);
    slope_orderMag = floor(log10(slope_mag));
    intercept = linReg(LINREG_INTERCEPT_IDX);
    if ~all(steadyState(channel_idx))
        slopeArray(channel_idx) = slope;
        interceptArray(channel_idx) = intercept;
    end
    % coefficient of determination
    linEval = polyval(linReg,timeArray);
    residual = steadyState - linEval;
    squareSumResidual = sum(residual.^2);
    steadyState_len = length(steadyState);
    squareSumTotal = (steadyState_len - 1) * var(steadyState);
    rSquare = 1 - squareSumResidual / squareSumTotal;
    regressionArray(channel_idx) = rSquare(1);
    
    % Capture steady state
    current_mag = abs(average);                                 % current magnitude
    current_orderMag = floor(log10(current_mag));               % current order of magnitude
%     current_power = 10^current_orderMag;
%     current_coeff = current_mag / current_power;
    steadyState_orderMag = current_orderMag - STEADY_STATE_MAG; % steady state order of magnitude
%     if bufferLength > DEFAULT_LENGTH
%         factor = floor(log10(bufferLength)) - 2;
%         steadyState_orderMag = steadyState_orderMag - factor;
%     end
    steadyStateSlope_power = 10^steadyState_orderMag;
%     steadyStateSlope(channel_idx) = current_coeff * steadyStateSlope_power; 	% steady state slope
    steadyStateSlope(channel_idx) = STEADY_STATE_COEFF * steadyStateSlope_power; 	% steady state slope
    percentDiff = abs(intercept-current_mag) / current_mag * 100;
    if bufferLength_now == bufferLength
        isBufferFull = true;
        if slope_orderMag <= steadyState_orderMag
%         if percentDiff < 10
            steadyState(channel_idx) = mean(latestCurrent);
            slopeArray(channel_idx) = slope;
            interceptArray(channel_idx) = intercept;
        end
        % Delete first index in buffer
        bufferShift = bufferMatrix(channel_idx,2:end);
        bufferMatrix(channel_idx,1:end-1) = bufferShift;
    end
    averageArray(channel_idx) = average;
    stdDevArray(channel_idx) = stdDev;
    percentDiffArray(channel_idx) = percentDiff;
    if ~all(steadyState(channel_idx))
        steadyStateArray(channel_idx) = 0;
    else
        value = steadyState(channel_idx);
        steadyStateArray(channel_idx) = value;
    end
end

% Print table
fullTable = table(...
    channelNameList,...
    steadyStateSlope,...
    steadyStateArray,...
    dataArray,...
    slopeArray,...
    averageArray,...
    stdDevArray,...
    'VariableNames',TABLE_HEADING);
%     percentDiffArray,...
fprintf('Samples: N = %d\n',sampleNum);
fprintf('Sample Time: t = %.2f s\n',sampleTime);
fprintf('Buffer Length: n = %g\n',bufferLength);
fprintf('Acceptable Standard Deviation: +/-%g SD\n',numOfStdDev);
disp(fullTable);

% If all at steady state
% isAllAtSteadyState = all(any(steadyStateRaw,ROWS_IDX));
isAllAtSteadyState = all(steadyState);
if isAllAtSteadyState == true
    isSteadyStateFound = 1;
end

end