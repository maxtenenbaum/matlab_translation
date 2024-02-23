function startingIncreaseStep_idx = getIncreaseStep(timeStep,time,current,timeStamp)
%% Variables
data_len = length(time);
timeEnd = time(data_len);
startingIncreaseStep_idx = [];
samplingPeriod = mean(diff(time));

%% Function
progBar = waitbar(0,'Finding current increase');
while timeStamp < timeEnd
    timePeriod = timeStamp + timeStep - samplingPeriod;
    if timePeriod > timeEnd
        break;
    end
    if ~isempty(progBar)
        percentage = timeStamp / timeEnd;
        waitbar(percentage,progBar,'Finding current increase');
    end

    start_idx = find(time == timeStamp);
    end_idx = find(time == timePeriod);
    step_idx = start_idx:end_idx;
    step_len = length(step_idx);
    currentStep_arr = current(step_idx);
    currentStart = currentStep_arr(1);
    currentLast = currentStep_arr(step_len);
    isCurrentStepIncrease = currentLast > currentStart;
    [slope,~,~] = getLinReg(step_idx,currentStep_arr);
    currentAvg = mean(currentStep_arr);
    currentAvg_pow = floor(log10(currentAvg));
    slopeCheck = 10^(currentAvg_pow);
    isCurrentStepSlope = slope > slopeCheck;
    if isCurrentStepIncrease || isCurrentStepSlope
        percentage = timeStamp / timeEnd;
        waitbar(percentage,progBar,'Current increase found');
        fprintf('current increase at %g s...',timeEnd);
        startingIncreaseStep_idx = find(time == timeStamp);
        break;
    end
    timeStamp = timePeriod + samplingPeriod;
end
delete(progBar);

end