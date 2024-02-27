function [paramStruct] = initParam(expInfo)
%% Constants
TYPE_IT = 'IT';
TYPE_IV = 'IV';
TYPE_CAP = 'CAP';
TYPE_STEP = 'STEP';

%% Variables
choice = '';
expID = expInfo.ID;

%% Function
if contains(expID,TYPE_IT,'IgnoreCase',true)
    choice = TYPE_IT;
    choiceDisp = 'current vs. time';
elseif contains(expID,TYPE_IV,'IgnoreCase',true)
    choice = TYPE_IV;
    choiceDisp = 'current vs. voltage';
elseif contains(expID,TYPE_CAP,'IgnoreCase',true)
    choice = TYPE_CAP;
    choiceDisp = 'capacitance';
elseif contains(expID,TYPE_STEP,'IgnoreCase',true)
    choice = TYPE_STEP;
    choiceDisp = 'step voltage';
end
fprintf('Saving %s parameters...',choiceDisp);

switch choice
    case TYPE_IT
        paramStruct = struct(...	% initialize structure
            'Channels',[],...
            'VoltageBias',[],...    % voltage bias
            'Duration',[]);    	    % duration
    case TYPE_IV
        paramStruct = struct(...	% initialize structure
            'Channels',[],...
            'LowerLimit',[],...
            'UpperLimit',[],...
            'StartingVoltage',[],...%
            'VoltageStep',[],...    % voltage step size
            'Cycles',[],...
            'VoltageList',[],...
            'NumberOfSteps',[],...
            'BufferLength',[],...
            'StandardDeviations',[]);
    case TYPE_CAP
        paramStruct = struct(...	% initialize structure
            'Channels',[],...
            'LowerLimit',[],...
            'UpperLimit',[],...
            'StartingVoltage',[],...%
            'VoltageStep',[],...    % voltage step size
            'TimeStep',[],...
            'Cycles',[],...
            'VoltageList',[],...
            'NumberOfSteps',[]);
    case TYPE_STEP
        paramStruct = struct(...	% initialize structure
            'Channels',[],...
            'TimeStep',[],...       % time
            'VoltageStep',[],...
            'StartingVoltage',[],...
            'EndingVoltage',[],...
            'Sweeps',[],...
            'VoltageList',[],...
            'NumberOfSteps',[]);
end
fprintf('OK.\n');   % structure initialized

end