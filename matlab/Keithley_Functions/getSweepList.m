function [sweepList,sweepStart_arr] = getSweepList(File)
%% Variables
voltageStart = File.Experiment.Parameters.StartingVoltage;
voltageEnd = File.Experiment.Parameters.EndingVoltage;
voltageList = File.Experiment.Parameters.VoltageList;
numOfSteps = File.Experiment.Parameters.NumberOfSteps;
numOfSweeps = File.Experiment.Parameters.Sweeps;
sweepList = cell(1,numOfSweeps);

%% Function
stepAtSweepStart_idx = find(voltageList == voltageStart);
stepAtSweepEnd_idx = find(voltageList == voltageEnd);
sweepStart_arr = voltageList(stepAtSweepStart_idx);

for sweepNum = 1:numOfSweeps
    sweepStart = stepAtSweepStart_idx(sweepNum);
    if sweepNum == numOfSweeps
        sweepEnd = numOfSteps;
    else
        sweepEnd = stepAtSweepEnd_idx(sweepNum);
    end
    sweep_arr = sweepStart:sweepEnd;
    sweepList{sweepNum} = sweep_arr;
end

end