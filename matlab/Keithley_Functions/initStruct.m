function [structType] = initStruct(type)
%% Constants
TYPE_FILE = 'FILE';
TYPE_CT = 'CT';
TYPE_CT_ALL = 'COMPIL';
TYPE_IV = 'IV';
TYPE_STEPS = 'STEP';
TYPE_EXCLUDE = 'EXCLU';

%% Variables
choice = '';

%% Function
if contains(type,TYPE_FILE,'IgnoreCase',true)
    choice = TYPE_FILE;
    choiceDisp = 'FILE';
elseif contains(type,TYPE_CT,'IgnoreCase',true)
    choice = TYPE_CT;
    choiceDisp = 'CT';
elseif contains(type,TYPE_CT_ALL,'IgnoreCase',true)
    choice = TYPE_CT_ALL;
    choiceDisp = 'compiled CT';
elseif contains(type,TYPE_IV,'IgnoreCase',true)
    choice = TYPE_IV;
    choiceDisp = 'IV';
elseif contains(type,TYPE_STEPS,'IgnoreCase',true)
    choice = TYPE_STEPS;
    choiceDisp = 'Steps';
elseif contains(type,TYPE_EXCLUDE,'IgnoreCase',true)
    choice = TYPE_EXCLUDE;
    choiceDisp = 'Exclusion';
end
fprintf('Initializing %s database...',choiceDisp);

switch choice
    case TYPE_FILE
        structType = struct(...	% initialize structure
            'Notebook',[],...           % notebook
            'Subject',[],...            % subject
            'Experiment',[],...         % parameters
            'Data',[],...               % data
            'DateTimeCreated',[],...    % date and time created
            'DateTimeModified',[],...   % date and time completed
            'RecordedBy',[],...         % name
            'Email',[]);                % email
    case TYPE_CT
        structType = struct(...	% initialize structure
            'Subject',[],...    % subject name
            'Voltage',[],...    % voltage bias
            'Channel',[],...    % channel name
            'Time',[],...       % time
            'Current',[],...    % leakage curent
            'DateTimeStart',[],...  % date and time started
            'DateTimeEnd',[]);    	% date and time ended
    case TYPE_CT_ALL
        structType = struct(...	% initialize structure
            'Subject',[],...    % subject name
            'Channel',[],...    % channel name
            'Voltage',[],...    % voltage bias
            'Time',[],...       % time
            'Current',[],...    % leakage curent
            'DateTimeStart',[],...  % date and time started
            'DateTimeEnd',[]);    	% date and time ended
    case TYPE_IV
        structType = struct(...	% initialize structure
            'Subject',[],...    % subject name
            'Channel',[],...    % channel name
            'Voltage',[],...    % voltage bias
            'Current',[],...    % leakage curent
            'DateTimeStart',[],...  % date and time started
            'DateTimeEnd',[]);    	% date and time ended
    case TYPE_STEPS
        structType = struct(...	% initialize structure
            'Subject',[],...    % subject name
            'Channel',[],...    % channel name
            'Time',[],...       % time
            'Voltage',[],...    % voltage bias
            'Current',[],...    % leakage curent
            'DateTimeStart',[],...  % date and time started
            'DateTimeEnd',[]);    	% date and time ended
    case TYPE_EXCLUDE
        structType = struct(...
            'Index',[],...
            'Time',[],...
            'Current',[]);
end
fprintf('OK.\n');   % structure initialized

end