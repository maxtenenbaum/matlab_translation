function StructType = initStruct2(type)
%% Constants
TYPE_FILE = 'FILE';
TYPE_INSTR = 'INSTR';
TYPE_STEADY = 'STEADY';
TYPE_SET = 'SET';
TYPE_BUFF = 'BUFF';
TYPE_EXP = 'EXP';
TYPE_CH = 'CH';
TYPE_IT = 'IT';
TYPE_IV = 'IV';
TYPE_CAP = 'CAP';
TYPE_STEP = 'STEP';
TYPE_EXCLUDE = 'EXCLU';

%% Variables
choice = '';

%% Function
if contains(type,TYPE_FILE,'IgnoreCase',true)
    choice = TYPE_FILE;
    choiceDisp = 'file';
elseif contains(type,TYPE_INSTR,'IgnoreCase',true)
    choice = TYPE_INSTR;
    choiceDisp = 'instrument';
elseif contains(type,TYPE_STEADY,'IgnoreCase',true)
    choice = TYPE_STEADY;
    choiceDisp = 'steady-state';
elseif contains(type,TYPE_SET,'IgnoreCase',true)
    choice = TYPE_SET;
    choiceDisp = 'settings';
elseif contains(type,TYPE_BUFF,'IgnoreCase',true)
    choice = TYPE_BUFF;
    choiceDisp = 'buffer';
elseif contains(type,TYPE_EXP,'IgnoreCase',true)
    choice = TYPE_EXP;
    choiceDisp = 'experiment';
elseif contains(type,TYPE_CH,'IgnoreCase',true)
    choice = TYPE_CH;
    choiceDisp = 'channels';
elseif contains(type,TYPE_IT,'IgnoreCase',true)
    choice = TYPE_IT;
    choiceDisp = 'current vs. time';
elseif contains(type,TYPE_IV,'IgnoreCase',true)
    choice = TYPE_IV;
    choiceDisp = 'current vs. voltage';
elseif contains(type,TYPE_CAP,'IgnoreCase',true)
    choice = TYPE_CAP;
    choiceDisp = 'capacitance';
elseif contains(type,TYPE_STEP,'IgnoreCase',true)
    choice = TYPE_STEP;
    choiceDisp = 'step voltage';
elseif contains(type,TYPE_EXCLUDE,'IgnoreCase',true)
    choice = TYPE_EXCLUDE;
    choiceDisp = 'exclusion';
end
fprintf('Initializing %s database...',choiceDisp);

switch choice
    case TYPE_FILE
        StructType = struct(...	% initialize structure
            'Notebook',[],...           % notebook
            'Subject',[],...            % subject
            'Instrument',[],...
            'Experiment',[],...         % experiment
            'Data',[],...               % data
            'Path',[],...
            'DateTimeCreated',[],...    % date and time created
            'DateTimeModified',[],...   % date and time completed
            'RecordedBy',[],...         % name
            'Email',[]);                % email
    case TYPE_EXP
        StructType = struct(...	% initialize structure
            'Type',[],...       % type
            'ID',[],...         % ID
            'Channels',[],...
            'Parameters',[],... % parameters
            'Quit',[]);   
    case TYPE_CH
        StructType = struct(...	% initialize structure
            'Number',[],...       % type
            'Name',[]);         % ID
    case TYPE_INSTR
        StructType = struct(...
            'Resource',[],...
            'Object',[],...
            'SteadyState',...
            'Settings');
    case TYPE_STEADY
        StructType = struct(...
            'BufferLength',[],...
            'StandardDeviations',[],...
            'Data',[]);
    case TYPE_SET
        StructType = struct(...
            'Display',[],...
            'PowerLine',[],...
            'SourceDelay',[],...
            'CurrentRange',[],...
            'Speed',[],...
            'AutoZero',[],...
            'GroundConnectMode',[],...
            'Channels',[],...
            'RelativeOffset',[],...
            'Buffer',[]);
    case TYPE_BUFF
        StructType = struct(...
            'Points',[],...
            'SamplingRate',[]); 
    case TYPE_IT
        StructType = struct(...	% initialize structure
            'Channel',[],...    % channel name
            'Voltage',[],...    % voltage bias
            'Time',[],...       % time
            'Current',[],...    % leakage curent
            'DateTimeStart',[],...  % date and time started
            'DateTimeEnd',[]);    	% date and time ended
    case TYPE_IV
        StructType = struct(...	% initialize structure
            'Channel',[],...    % channel name
            'Voltage',[],...    % voltage bias
            'Current',[],...    % leakage curent
            'StepData',[],...
            'Resistance',[],...
            'DateTimeStart',[],...  % date and time started
            'DateTimeEnd',[]);    	% date and time ended
    case TYPE_CAP
        StructType = struct(...	% initialize structure
            'Channel',[],...    % channel name
            'Voltage',[],...    % voltage bias
            'Current',[],...    % leakage curent
            'StepData',[],...
            'Capacitance',[],...
            'DateTimeStart',[],...  % date and time started
            'DateTimeEnd',[]);    	% date and time ended
    case TYPE_STEP
        StructType = struct(...	% initialize structure
            'Channel',[],...    % channel name
            'Time',[],...       % time
            'Voltage',[],...    % voltage bias
            'Current',[],...    % leakage curent
            'DateTimeStart',[],...  % date and time started
            'DateTimeEnd',[]);    	% date and time ended
    case TYPE_EXCLUDE
        StructType = struct(...
            'Index',[],...
            'Time',[],...
            'Current',[]);
end
fprintf('OK\n');   % structure initialized

end