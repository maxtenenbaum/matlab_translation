function [File,quitProgram] = getParamStep(File)
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
DIMS_DIALOG = [1 70];
% Values
YES = true;
LIMIT_30V = 30;             % max 30 V

%% Variables
confirmVoltageParam = false;
quitProgram = false;
% voltageStart = [];
% voltageEnd = [];
% voltageStep = [];
% timeStep = [];
% numOfSweeps = [];
%% Function
fprintf('Enter voltage parameters...');

while confirmVoltageParam == false
    % Dialog box
    titleInputProgVoltageParam = 'Voltage Parameters';                  % input title
    promptInputProgVoltageParam = {...                                  % input prompt
        'Starting voltage (V) {\bf(between \pm30)}:',...                % starting voltage (V)
        'Ending voltage (V) {\bf(between \pm30)}:',...                  % ending voltage (V)
        'Step Size (V):',...                                            % step size (V)
        'Time Step (s):',...                                            % time step (s)
        'Sweeps: {\bf(Number of of times from start to end)}:'};
    defaultInputProgVoltageParam = {'0','30','0.1','','1'};% input defaults
    inputProgVoltageParam = inputdlg(... % input dialog
        promptInputProgVoltageParam,...  % input prompts
        titleInputProgVoltageParam,...	% input title
        DIMS_DIALOG,...             % dialog dimensions
        defaultInputProgVoltageParam,... % input defaults
        opts);                      % dialog options
    cancelProgVoltageParam = isempty(inputProgVoltageParam);    % cancel dialog
    if cancelProgVoltageParam == true                  % cancel detected
        fprintf('\nQuitting...');                    % quitting
        quitProgram = true;
        return;                                         % exit program
    end

    % Collect input
    voltageStart_cell = inputProgVoltageParam{1};   % starting voltage (cell)
    voltageStart = str2double(voltageStart_cell);   % starting voltage (double)
    voltageEnd_cell = inputProgVoltageParam{2};     % starting voltage (cell)
    voltageEnd = str2double(voltageEnd_cell);       % starting voltage (double)
    voltageStep_cell = inputProgVoltageParam{3};       % step size (cell)
    voltageStep = str2double(voltageStep_cell);           % step size (double)
    timeStep_cell = inputProgVoltageParam{4};       % step size (cell)
    timeStep = str2double(timeStep_cell);           % step size (double)
    numOfSweeps_cell = inputProgVoltageParam{5}; 	% number of repeats (cell)
    numOfSweeps = str2double(numOfSweeps_cell);   % number of repeats (double)

    progVoltageStartInvalid = abs(voltageStart) > LIMIT_30V;
    progVoltageEndInvalid = abs(voltageEnd) > LIMIT_30V;
    progVoltageInvalid = progVoltageStartInvalid || progVoltageEndInvalid;
    if progVoltageInvalid == YES
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
    titleQuestProgVoltageParam = 'Confirm Progressive Voltage';
    % Format questions
    voltageStart_use = sprintf('Starting voltage: {\\bf%g V}',voltageStart);% formatted starting voltage
    voltageEnd_use = sprintf('Ending voltage: {\\bf%g V}',voltageEnd);      % formatted ending voltage
    stepSize_use = sprintf('Step size: {\\bf%g V}',voltageStep);               % formatted step size
    timeStep_use = sprintf('Time step: {\\bf%g s}',timeStep);           % formatted time step
    numOfSweeps_use = sprintf('Number of repeats: {\\bf%g}',numOfSweeps);

    promptQuestVoltageParam = {...  % question prompt
        voltageStart_use,...        % starting voltage
        voltageEnd_use,...          % ending voltage
        stepSize_use,...            % step size
        timeStep_use,...            % time step
        numOfSweeps_use};

    % Question box
    questVoltageParam = questdlg(...                % question dialog
        promptQuestVoltageParam,...                 % question prompt
        titleQuestProgVoltageParam,...                   % question title
        BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
        opts);                                      % dialog options
    % Confirmation
    switch questVoltageParam        % apply choice
        case BUTTON_CONFIRM         % check confirmation
            confirmVoltageParam = true;% confirm parameters
            File.Experiment.Parameters.VoltageStep = voltageStep;
            File.Experiment.Parameters.TimeStep = timeStep;
            File.Experiment.Parameters.StartingVoltage = voltageStart;
            File.Experiment.Parameters.EndingVoltage = voltageEnd;
            File.Experiment.Parameters.Sweeps = numOfSweeps;
            File = getVoltageList(File);
            fprintf('OK.\n');       % parameters confirmed
        case BUTTON_TRY                     % try again
            fprintf('\nTrying again...\n\n'); % starting over
        case BUTTON_CANCEL                  % quit
            fprintf('\nQuitting...');     % quitting
            quitProgram = true;
            return;                         % exit program
        otherwise                           % cancel
            fprintf('\nQuitting...');     % quitting
            quitProgram = true;
            return;                         % exit program
    end
end

end