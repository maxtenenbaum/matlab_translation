function [cycleList,cycleStart_arr] = getCycleList(File)
%% Variables
voltageStart = File.Experiment.Parameters.StartingVoltage;
voltageList = File.Experiment.Parameters.VoltageList;
numOfCycles = File.Experiment.Parameters.Cycles;
numOfSteps = File.Experiment.Parameters.NumberOfSteps;
cycleList = cell(1,numOfCycles);

%% Function
stepAtVoltageStart = find(voltageList == voltageStart);
stepAtVoltageStart_len = length(stepAtVoltageStart);
stepAtCycleStart_idx = [];
for step_idx = 1:stepAtVoltageStart_len-1
    if rem(step_idx,2) == 1
        stepAtCycleStart_idx_alloc = [stepAtCycleStart_idx,step_idx];
        stepAtCycleStart_idx = stepAtCycleStart_idx_alloc;
    end
end
cycleStart_arr = stepAtVoltageStart(stepAtCycleStart_idx);

for cycleNum = 1:numOfCycles
    cycleStart = cycleStart_arr(cycleNum);
    if cycleNum == numOfCycles
        cycleEnd = numOfSteps;
    else
        cycleEnd = cycleStart_arr(cycleNum+1);
    end
    step_arr = cycleStart:cycleEnd;
    cycleList{cycleNum} = step_arr;
end

end