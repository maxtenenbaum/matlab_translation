function failure_idx = findFailureIndexAtChange2(timeStep,time,current)
%% Constants
MICROAMP = 1e-6;
NANOAMP = 1e-9;

%% Variables
data_len = length(time);
failure_idx = [];

%% Function
% fprintf('Finding failure...');
if all(current > MICROAMP)
    fprintf('all current above 1 uA...');
    failure_idx = 1;
    return;
else
    if all(current > NANOAMP)
        fprintf('all current above 1 nA...');
        failure_idx = 1;
        return;
    end
end

while isempty(failure_idx)
    startingCapacitive_idx = getCapacitiveStep(timeStep,time,current,0);
    if ~isempty(startingCapacitive_idx)
        timeStamp = time(startingCapacitive_idx);
        startingFaradaicStep_idx = getFaradaicStep(timeStep,time,current,timeStamp);
        startingIncreaseStep_idx = getIncreaseStep(timeStep,time,current,timeStamp);
        failure_idx = min([startingFaradaicStep_idx startingIncreaseStep_idx]);
        timeStamp = time(failure_idx);
        fprintf('failure at %g s\n',timeStamp);

        otherCapacitive_idx = getCapacitiveStep(timeStep,time,current,timeStamp);
        while ~isempty(otherCapacitive_idx)
            otherTimeStamp = time(otherCapacitive_idx);
            otherFaradaicStep_idx = getFaradaicStep(timeStep,time,current,otherTimeStamp);
            otherIncreaseStep_idx = getIncreaseStep(timeStep,time,current,otherTimeStamp);
            checkFailure_idx = min([otherFaradaicStep_idx otherIncreaseStep_idx]);
            currrentCheck = current(checkFailure_idx);
            if currrentCheck < MICROAMP
                failure_idx = checkFailure_idx;
                timeStamp = time(failure_idx);
                fprintf('failure at %g s\n',timeStamp);
                if otherCapacitive_idx < data_len
                    otherCapacitive_idx = getCapacitiveStep(timeStep,time,current,failure_idx);
                    if isempty(otherCapacitive_idx)
                        break;
                    end
                else
                    break;
                end
            else
                break;
            end            
        end
    else
        failure_idx = getIncreaseStep(timeStep,time,current,idx);
    end

end

end