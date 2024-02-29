function [lowerLimit,upperLimit,voltageStart,stepSize,numOfCycles,quitProgram] = getVoltageParam()
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
DIMS_DIALOG = [1 55];
% Values
LIMIT_30V = 30;             % max 30 V

%% Variables
confirmVoltageParam = 0;
quitProgram = 0;

%% Function
fprintf('Enter voltage parameters...');

try
    while confirmVoltageParam == 0    
        % Dialog box
        titleInputVoltageStart = 'Voltage Parameters';      % input title
        promptInputVoltageStart = {...                      % input prompt
            'Lower Limit (V) {\bf(between \pm30)}:',...    	% lower voltage limit (V)
            'Upper limit (V) {\bf(between \pm30)}:',...   	% upper voltage limit (V)
            'Starting voltage (V) {\bf(between \pm30)}:',...% starting voltage (V)
            'Step Size (V) {\bf(Use negative to move right first)}:',...% step size (V)
            'Number of cycles:'};                                       % number of cycles
        defaultInputVoltageStart = {'-5','5','0','1','1'};	% input defaults
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
        stepSize_cell = inputVoltageStart{4};           % step size (cell)
        stepSize = str2double(stepSize_cell);           % step size (double)
        numOfCycles_cell = inputVoltageStart{5};        % number of cycles (cell)
        numOfCycles = str2double(numOfCycles_cell);    	% number of cycles (double)
        if cancelVoltageStart == 1                      % cancel detected
            fprintf('\nQuitting...');                   % quitting
            quitProgram = 1;
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
                    quitProgram = 1;
                    return;                         % exit program
                otherwise                           % cancel
                    fprintf('Quitting...');     % quitting
                    quitProgram = 1;
                    return;                         % exit program
            end
        end

        % Confirm voltage parameters
        titleQuestVoltageParam = 'Confirm Voltage Parameters';
        % Format questions
        lowerLimit_use = sprintf('Lower limit: {\\bf%g V}',lowerLimit);         % formatted lower limit
        upperLimit_use = sprintf('Upper limit: {\\bf%g V}',upperLimit);         % formatted upper limit
        voltageStart_use = sprintf('Starting voltage: {\\bf%g V}',voltageStart);% formatted starting voltage
        stepSize_use = sprintf('Step size: {\\bf%g V}',stepSize);               % formatted step size
        numOfCycles_use = sprintf('Number of cycles: {\\bf%g}',numOfCycles);	% formatted number of cycles

        promptQuestVoltageParam = {...  % question prompt
            lowerLimit_use,...          % lower limit
            upperLimit_use,...          % upper limit
            voltageStart_use,...        % starting voltage
            stepSize_use,...            % step size
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
                confirmVoltageParam = 1;                % confirm parameters
                fprintf('OK.\n'); % parameters confirmed
            case BUTTON_TRY                     % try again
                fprintf('\nTrying again...\n\n'); % starting over
            case BUTTON_CANCEL                  % quit
                fprintf('\nQuitting...');     % quitting
                quitProgram = 1;
            otherwise                           % cancel
                fprintf('\nQuitting...');     % quitting
                quitProgram = 1;
        end
    end
catch
    lowerLimit = 0;
    upperLimit = 0;
    voltageStart = 0;
    stepSize = 0;
    numOfCycles = 0;
    quitProgram = 1;
end

end