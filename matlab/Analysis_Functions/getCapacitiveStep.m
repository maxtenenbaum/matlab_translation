function startingCapacitive_idx = getCapacitiveStep(timeStep,time,current,timeStamp)
%% Variables
data_len = length(time);
timeEnd = time(data_len);
startingCapacitive_idx = [];
samplingPeriod = mean(diff(time));

%% Function
progBar = waitbar(0,'Finding capacitive step');
while timeStamp < timeEnd
    timePeriod = timeStamp + timeStep - samplingPeriod;
    if timePeriod > timeEnd
        break;
    end
    if ~isempty(progBar)
        percentage = timeStamp / timeEnd;
        waitbar(percentage,progBar,'Finding capacitive step');
    end
    
    start_idx = find(time == timeStamp);
    end_idx = find(time == timePeriod);
    step_idx = start_idx:end_idx;
    step_len = length(step_idx);
    timeStep_arr = zeros(step_len,1);
    currentStep_arr = zeros(step_len,1);
    timeStep_arr(:) = time(step_idx);
    currentStep_arr(:) = current(step_idx);
    currentStart = currentStep_arr(1);
    currentLast = currentStep_arr(step_len);
    isCurrentStepIncrease = currentLast > currentStart;
%     try
%         [~,gof] = fit(timeStep_arr',currentStep_arr','exp1');
%         corr = gof.rsquare;
%     catch
%         corr = 0;
%     end
    [coeff,gof] = fit(timeStep_arr,currentStep_arr,'exp1');
%     a = coeff.a;
    b = coeff.b;
    isExpDecay = b < 0;
    corr = gof.rsquare;
    isExpFit = corr > 0.80;
    if isExpFit && isExpDecay && ~isCurrentStepIncrease
        if ~isempty(progBar)
            percentage = timeStamp / timeEnd;
            waitbar(percentage,progBar,'Capacitive step found');
        end
        fprintf('capacitive step at %g s...',timeStamp);
        startingCapacitive_idx = find(time == timeStamp);
        break;
    end
    timeStamp = timePeriod + samplingPeriod;
end
delete(progBar);

end