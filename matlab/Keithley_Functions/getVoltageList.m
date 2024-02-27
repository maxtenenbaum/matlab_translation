function File = getVoltageList(File)
%% Variables
Parameters = File.Experiment.Parameters;
fields = fieldnames(Parameters);
isIV = false;

%% Function
if any(contains(fields,'Cycles','IgnoreCase',true))
    lowerLimit = File.Experiment.Parameters.LowerLimit;
    upperLimit = File.Experiment.Parameters.UpperLimit;
    voltageStart = File.Experiment.Parameters.StartingVoltage;
    voltageStep = File.Experiment.Parameters.VoltageStep;
    numOfCycles = File.Experiment.Parameters.Cycles;
    isIV = true;
elseif any(contains(fields,'Sweeps','IgnoreCase',true))
    lowerLimit = File.Experiment.Parameters.StartingVoltage;
    upperLimit = File.Experiment.Parameters.EndingVoltage;
    voltageStart = lowerLimit;
    voltageStep = File.Experiment.Parameters.VoltageStep;
    numOfCycles = File.Experiment.Parameters.Sweeps;
end

% Voltage list
stepSize_sign = sign(voltageStep);
stepSize_mag = abs(voltageStep);
listVoltageSteps = lowerLimit:stepSize_mag:upperLimit;
if stepSize_sign == -1
    listVoltageSteps = flip(listVoltageSteps);
end

if isIV
    % Voltage step cycle
    voltageStart_idx = find(listVoltageSteps == voltageStart);
    % forward
    voltageStepForward = listVoltageSteps(voltageStart_idx:end);
    % reverse
    listVoltageStepsFlip = flip(listVoltageSteps);
    voltageStepBackward = listVoltageStepsFlip(2:end);
    % return
    voltageStepReturn = listVoltageSteps(2:voltageStart_idx);
    voltageStepCycle = [voltageStepForward,voltageStepBackward,voltageStepReturn];
    % cycle
    if numOfCycles == 1
        voltageList = voltageStepCycle;
    else
        voltageStepCycle_fix = voltageStepCycle(2:end);
        voltageStepCycle_full = [];
        for cycleNum = 1:numOfCycles
            if cycleNum == 1
                voltageStepCycle_full_alloc = [voltageStepCycle_full,voltageStepCycle];
            else
                voltageStepCycle_full_alloc = [voltageStepCycle_full,voltageStepCycle_fix];
            end
            voltageStepCycle_full = voltageStepCycle_full_alloc;
        end
        voltageList = voltageStepCycle_full;
    end
else
    voltageList = listVoltageSteps;
end


File.Experiment.Parameters.VoltageList = transpose(voltageList);
File.Experiment.Parameters.NumberOfSteps = length(voltageList);

end