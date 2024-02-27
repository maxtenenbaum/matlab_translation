function [File,quitProgram] = getParamCap(File)
%% Constants
% Dialog
% buttons
BUTTON_CONFIRM = 'Confirm'; % confirm button
BUTTON_TRY = 'Start Over';  % start over button
BUTTON_CANCEL = 'Cancel';   % cancel button
% titles
TITLE_ERROR = 'ERROR';
% options
opts.Default = 'yes';       % option dedault
opts.Interpreter = 'tex';   % option LaTeX
% dimensions
DIMS_DIALOG = [1 60];
% Values
LIMIT_30V = 30;             % max 30 V

%% Variables
confirmVoltageParam = false;
quitProgram = false;
lowerLimit = [];
upperLimit = [];
voltageStart = [];
voltageStep = [];
numOfCycles = [];

%% Function
fprintf('Enter voltage parameters...');

while confirmVoltageParam == false
    % Dialog box
    titleInputVoltageStart = 'Voltage Parameters';      % input title
    promptInputVoltageStart = {...                      % input prompt
        'Lower Limit (V) {\bf(between \pm30)}:',...    	% lower voltage limit (V)
        'Upper limit (V) {\bf(between \pm30)}:',...   	% upper voltage limit (V)
        'Starting voltage (V) {\bf(between \pm30)}:',...% starting voltage (V)
        'Voltage step size (V) {\bf(Use negative to move left first)}:',...% step size (V)
        'Time step size (s):',...% step size (s)
        'Number of cycles:'};                                       % number of cycles
    defaultInputVoltageStart = {'-5','5','0','0.1','60','1'};	% input defaults
    inputVoltageStart = inputdlg(...% input dialog
        promptInputVoltageStart,... % input prompts
        titleInputVoltageStart,...	% input title
        DIMS_DIALOG,...             % dialog dimensions
        defaultInputVoltageStart,...% input defaults
        opts);                      % dialog options
    cancelVoltageStart = isempty(inputVoltageStart);    % cancel dialog

    % Collect input
    lowerLimit_cell = inputVoltageStart{1};         % lower limit (cell)
    lowerLimit = str2double(lowerLimit_cell);       % lower limit (double)
    upperLimit_cell = inputVoltageStart{2};         % upper limit (cell)
    upperLimit = str2double(upperLimit_cell);       % upper limit (double)
    voltageStart_cell = inputVoltageStart{3};       % starting voltage (cell)
    voltageStart = str2double(voltageStart_cell);   % starting voltage (double)
    voltageStep_cell = inputVoltageStart{4};        % step size (cell)
    voltageStep = str2double(voltageStep_cell);     % step size (double)
    timeStep_cell = inputVoltageStart{5};        % step size (cell)
    timeStep = str2double(timeStep_cell);     % step size (double)
    numOfCycles_cell = inputVoltageStart{6};        % number of cycles (cell)
    numOfCycles = str2double(numOfCycles_cell);    	% number of cycles (double)
    if cancelVoltageStart == true                      % cancel detected
        fprintf('\nQuitting...');                   % quitting
        quitProgram = true;
        return;                                         % exit program
    end

    isLowerLimitInvalid = abs(lowerLimit) > LIMIT_30V;
    isUpperLimitInvalid = abs(upperLimit) > LIMIT_30V;
    voltageStartInvalid = abs(upperLimit) > LIMIT_30V;
    if isLowerLimitInvalid || isUpperLimitInvalid || voltageStartInvalid
        prompt1 = 'VOLTAGE VALUE(S) OUTSIDE RANGE!';
        disp(prompt1);
        prompt2 = 'Please enter correct value(s) within range.';
        prompt = {prompt1,prompt2};
        balance = questdlg(prompt,TITLE_ERROR,BUTTON_TRY,BUTTON_CANCEL,opts);
        switch balance
            case BUTTON_TRY                     % try again
                fprintf('Trying again...\n\n'); % starting over
            case BUTTON_CANCEL                  % quit
                fprintf('Quitting...');     % quitting
                quitProgram = true;
                return;                         % exit program
            otherwise                           % cancel
                fprintf('Quitting...');     % quitting
                quitProgram = true;
                return;                         % exit program
        end
    end

    % Confirm voltage parameters
    titleQuestVoltageParam = 'Confirm Voltage Parameters';
    % Format questions
    lowerLimit_use = sprintf('Lower limit: {\\bf%g V}',lowerLimit);         % formatted lower limit
    upperLimit_use = sprintf('Upper limit: {\\bf%g V}',upperLimit);         % formatted upper limit
    voltageStart_use = sprintf('Starting voltage: {\\bf%g V}',voltageStart);% formatted starting voltage
    voltageStep_use = sprintf('Voltage step size: {\\bf%g V}',voltageStep);               % formatted step size
    timeStep_use = sprintf('Time step size: {\\bf%g s}',timeStep);               % formatted step size
    numOfCycles_use = sprintf('Number of cycles: {\\bf%g}',numOfCycles);	% formatted number of cycles

    promptQuestVoltageParam = {...  % question prompt
        lowerLimit_use,...          % lower limit
        upperLimit_use,...          % upper limit
        voltageStart_use,...        % starting voltage
        voltageStep_use,...         % step size
        timeStep_use,...
        numOfCycles_use};           % number of cycles

    % Question box
    titleQuestVoltageParam = questdlg(...          	% question dialog
        promptQuestVoltageParam,...                 % question prompt
        titleQuestVoltageParam,...                  % question title
        BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
        opts);                                      % dialog options
    % Confirmation
    switch titleQuestVoltageParam                   % apply choice
        case BUTTON_CONFIRM                         % check confirmation
            confirmVoltageParam = true;                % confirm parameters
            File.Experiment.Parameters.LowerLimit = lowerLimit;
            File.Experiment.Parameters.UpperLimit = upperLimit;
            File.Experiment.Parameters.StartingVoltage = voltageStart;
            File.Experiment.Parameters.VoltageStep = voltageStep;
            File.Experiment.Parameters.TimeStep = timeStep;
            File.Experiment.Parameters.Cycles = numOfCycles;
            File = getVoltageList(File);
            fprintf('OK.\n'); % parameters confirmed
        case BUTTON_TRY                     % try again
            fprintf('\nTrying again...\n\n'); % starting over
        case BUTTON_CANCEL                  % quit
            fprintf('\nQuitting...');     % quitting
            quitProgram = true;
        otherwise                           % cancel
            fprintf('\nQuitting...');     % quitting
            quitProgram = true;
    end
end

end