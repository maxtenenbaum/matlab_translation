function [failure_idx] = findFailureIndex(timeStep,data_len,current,currentThresh)
%% Constants
FIRST = 1;
ONE = 1;
THOU = 1e3;

%% Function
failure_idx = [];
while isempty(failure_idx)
    if all(current > currentThresh)
        currentFail = current(FIRST);
        failure_idx = find(current == currentFail);
        break;
    end
    if all(current < currentThresh)
        currentThresh = currentThresh / THOU;
        if all(current > currentThresh)
            currentFail = current(FIRST);
            failure_idx = find(current == currentFail);
            break;
        end
    end
    
    idx = 1;
    while idx < data_len
        idx_final = idx + timeStep - ONE;
        interval = idx:idx_final;
        currentInterval = current(interval);
        doesCurrentIntervalFail = all(currentInterval > currentThresh);
        currentLast = currentInterval(end);
        doesCurrentLastFail = currentLast > currentThresh;
        if doesCurrentIntervalFail
            currentFail =  min(currentInterval);
            failure_idx = find(current == currentFail);
            if idx ~= ONE
                break;
            end
        elseif doesCurrentLastFail
            currentFail = currentLast;
            failure_idx = find(current == currentFail);
            if idx ~= ONE
                break;
            end
        end
        idx = idx + timeStep;
    end
end

end