function File = getProcessing2(File)
%% Constants
TABLE_HEADING = {...
    'Channel',...
    'Current (A)',...
    'Slope (A/n)',...
    'Mean (A)',...
    '+/-SD (A)'};
TABLE_HEADING_IV = {...
    'Channel',...
    'Current (A)',...
    'Steady State (A)',...
    'Slope (A/n)',...
    '|Steady State Slope| (A/n)',...
    'Mean (A)',...
    '+/-SD (A)'};

%% Variables
expID = File.Experiment.ID;
channelSelect = File.Experiment.Channels.Number;
channelNameList = transpose(File.Experiment.Channels.Name);
channelSelect_len = length(channelSelect);
if ~strcmpi(expID,'IT')
    stepNum = File.StepData(end).Step;
    sampleNum = File.Instrument.Processing(stepNum).NumberOfSamples;
    % isBufferFilled = File.Instrument.Processing(stepNum).Filled;
end

latestCurrent_arr = zeros(1,channelSelect_len);
slope_arr = zeros(1,channelSelect_len);
intercept_arr = zeros(1,channelSelect_len);
regression_arr = zeros(1,channelSelect_len);
mean_arr = zeros(1,channelSelect_len);
sd_arr = zeros(1,channelSelect_len);

%% Determine Experiment
expID = File.Experiment.ID;
if strcmpi(expID,'IV')
    bufferLength = File.Experiment.Parameters.BufferLength;
    numOfSD = File.Experiment.Parameters.StandardDeviations;
    % Steady state
    steadyStateMatrix = File.Instrument.SteadyState.Data;
    processed_arr = steadyStateMatrix(stepNum,:);
    steadyStateString_arr = string(processed_arr);
    steadyStateString_arr_zero = strcmpi(steadyStateString_arr,"0");
    steadyStateString_arr(steadyStateString_arr_zero) = "";
    % Slope
    steadyStateSlope_arr = zeros(1,channelSelect_len);
    steadyStateSlopeString_arr = strings(1,channelSelect_len);

    % Check buffer
    if sampleNum > bufferLength
        File.Instrument.Processing(stepNum).Filled = true;
        start = sampleNum - bufferLength + 1;
        sample_arr = start:sampleNum;
    else
        sample_arr = 1:sampleNum;
    end
else
    sample_arr = 1:sampleNum;
end



for channel_idx = 1:channelSelect_len
    % Create buffer
    if strcmpi(expID,'IT')
        time_arr = File.Data(channel_idx).Time;
        channelCurrent_arr = File.Data(channel_idx).Current;
    else
        time_arr = File.StepData(stepNum).Data(channel_idx).Time;
        channelCurrent_arr = File.StepData(stepNum).Data(channel_idx).Current;
    end
    latestCurrent_arr(channel_idx) = channelCurrent_arr(end);
    channelBuffer = channelCurrent_arr(sample_arr);

    % Buffer statistics
    channelAvg = mean(channelBuffer);
    channelSD = std(channelBuffer);

    % Exclude bad values from buffer
    acceptableSD = numOfSD * channelSD;
    acceptableSD_min = channelAvg + acceptableSD;
    acceptableSD_max = channelAvg - acceptableSD;
    valueTooHigh = find(channelBuffer > acceptableSD_min);
    valueTooLow = find(channelBuffer < acceptableSD_max);
    exclude_idx_raw = [valueTooHigh;valueTooLow];
    exclude_idx = sort(exclude_idx_raw);
    if strcmpi(expID,'IT')
        File.Data(channel_idx).Statistics.Exclude.Index = exclude_idx;
        File.Data(channel_idx).Statistics.Exclude.Time = time_arr(exclude_idx);
        File.Data(channel_idx).Statistics.Exclude.Current = channelBuffer(exclude_idx);
    else
        File.StepData(stepNum).Data(channel_idx).Statistics.Exclude.Index = exclude_idx;
        File.StepData(stepNum).Data(channel_idx).Statistics.Exclude.Time = time_arr(exclude_idx);
        File.StepData(stepNum).Data(channel_idx).Statistics.Exclude.Current = channelBuffer(exclude_idx);
    end

    %% Adjusted Buffer
    sample_arr(exclude_idx) = [];
    channelBuffer(exclude_idx) = [];
    channelAvg = mean(channelBuffer);
    channelSD = std(channelBuffer);
    mean_arr(channel_idx) = channelAvg;
    sd_arr(channel_idx) = channelSD;

    % Linear regression
    [slope,intercept,r2] = getLinReg (sample_arr,channelBuffer);
    slope_mag = abs(slope);
%     slope_pow = floor(log10(slope_mag));
    slope_arr(channel_idx) = slope;
    intercept_arr(channel_idx) = intercept;
    regression_arr(channel_idx) = r2;

    %% Capture steady state
    if strcmpi(expID,'IV')
        if sampleNum > bufferLength
            File.Instrument.Processing(stepNum).Filled = true;
            avg_mag = abs(channelAvg);
            avg_pow = floor(log10(avg_mag));               % current order of magnitude
%             avg_coeff = avg_mag / 10^avg_pow;
            steadyStateSlope_pow = avg_pow - 2; % steady state order of magnitude
            steadyStateSlope = 10^steadyStateSlope_pow;
%             steadyStateSlope_mag = avg_coeff * 10^steadyStateSlope_pow; 	% steady state slope
            steadyStateSlope_arr(channel_idx) = steadyStateSlope;
            steadyStateSlopeString_arr(channel_idx) = sprintf('%g',steadyStateSlope);
            isSteadyState = slope_mag < steadyStateSlope;
            if isSteadyState && steadyStateSlope ~= 0 && channelAvg ~= 0
                processed_arr(channel_idx) = channelAvg;
                steadyStateString_arr(channel_idx) = sprintf('%e',channelAvg);
            end
        end
    end

    if strcmpi(expID,'IT')
        File.Data(channel_idx).Statistics.Buffer = channelBuffer;
        File.Data(channel_idx).Statistics.Mean = channelAvg;
        File.Data(channel_idx).Statistics.StandardDeviations = channelSD;
        File.Data(channel_idx).Statistics.Slope = slope;
        File.Data(channel_idx).Statistics.Intercept = intercept;
        File.Data(channel_idx).Statistics.Regression = r2;
    else
        File.StepData(stepNum).Data(channel_idx).Statistics.Buffer = channelBuffer;
        File.StepData(stepNum).Data(channel_idx).Statistics.Mean = channelAvg;
        File.StepData(stepNum).Data(channel_idx).Statistics.StandardDeviations = channelSD;
        File.StepData(stepNum).Data(channel_idx).Statistics.Slope = slope;
        File.StepData(stepNum).Data(channel_idx).Statistics.Intercept = intercept;
        File.StepData(stepNum).Data(channel_idx).Statistics.Regression = r2;
    end
end

%% Save steady state
if strcmpi(expID,'IV')
    if all(processed_arr)
        File.StepData(stepNum).Completed = true;
    end
end
steadyStateMatrix(stepNum,:) = processed_arr;
File.Instrument.SteadyState.Data = steadyStateMatrix;

% Print table
if strcmpi(expID,'IV')    
    fullTable = table(...
        channelNameList',...
        latestCurrent_arr',...
        steadyStateString_arr',...
        slope_arr',...
        steadyStateSlopeString_arr',...
        mean_arr',...
        sd_arr',...
        'VariableNames',TABLE_HEADING_IV);
else
    % Print table
    fullTable = table(...
        channelNameList',...
        latestCurrent_arr',...
        slope_arr',...
        mean_arr',...
        sd_arr',...
        'VariableNames',TABLE_HEADING);
end
disp(fullTable);

end