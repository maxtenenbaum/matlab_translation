function File = findStepFailure(File,currentStep,channel_idx)
%% Variables
channelSelect = File.Experiment.Channels.Number;
channelNum = channelSelect(channel_idx);
channelNameList = File.Experiment.Channels.Name;
channelName = channelNameList(channel_idx);
isSwitchInitiated = File.Data(channel_idx).Failure.Found;
stepNum = length(File.StepData);

%% Check Beginning and End
currentStep_len = length(currentStep);
start_idx = 1:5;
end_idx = currentStep_len-5:currentStep_len;
currentStart = currentStep(start_idx);
currentEnd = currentStep(end_idx);
currentStart_mean = mean(currentStart);
currentEnd_mean = mean(currentEnd);
isCurrentIntervalChange = currentEnd_mean > currentStart_mean;

%% Check Linearity
sample_arr = 1:currentStep_len;
[slope,~,~] = getLinReg(sample_arr,currentStep);
current_mean = mean(currentStep);
current_pow = floor(log10(current_mean));
currentCheck_pow = current_pow - 3;
slopeCheck = 10^currentCheck_pow;
isCurrentIntervalSlope = slope > slopeCheck;

%% Check Exponentiality
try
    [~,gof] = fit(sample_arr,currentStep','exp1');
    corr = gof.rsquare;
catch
    corr = 0;
end
isExpFit = corr > 0.70;
if isExpFit
    isCapacitiveFound = true;
else
    isCapacitiveFound = false;
end

if ~isempty(isSwitchInitiated)
    if isCurrentIntervalChange && isCurrentIntervalSlope && isCapacitiveFound
        File.Data(channel_idx).Failure.Found = false; % need to next detect transition
        fprintf('Detected capcitive behavior for %s\n',channelName);
    end
elseif ~isSwitchInitiated
    if ~(isCurrentIntervalChange && isCurrentIntervalSlope && isCapacitiveFound)
        File.Data(channel_idx).Failure.Found = true;
        File.Data(channel_idx).Failure.Step = stepNum;
        setChannelVoltageBias(File,channelNum,voltageBias);
        fprintf('Detected onset failure for %s\n',channelName);
    end
end


end