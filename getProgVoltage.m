function [voltageStart,voltageEnd,stepSize,timeStep,numOfStdDev,quitProgram] = getProgVoltage()
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
YES = 1;
LIMIT_30V = 30;             % max 30 V

%% Variables
confirmVoltageParam = 0;
quitProgram = 0;

%% Function
fprintf('Enter voltage parameters...');

try
    while confirmVoltageParam == 0    
        % Dialog box
        titleInputProgVoltageParam = 'Voltage Parameters';                  % input title
        promptInputProgVoltageParam = {...                                  % input prompt
            'Starting voltage (V) {\bf(between \pm30)}:',...                % starting voltage (V)
            'Ending voltage (V) {\bf(between \pm30)}:',...                  % ending voltage (V)
            'Step Size (V):',...                                            % step size (V)
            'Time Step (s)',...                                             % time step (s)
            'Standard devations (s) {\bf(larger accepts more values)}:'};   % standard deviation
        defaultInputProgVoltageParam = {'0','30','0.1','60','3'};% input defaults
        inputProgVoltageParam = inputdlg(... % input dialog
            promptInputProgVoltageParam,...  % input prompts
            titleInputProgVoltageParam,...	% input title
            DIMS_DIALOG,...             % dialog dimensions
            defaultInputProgVoltageParam,... % input defaults
            opts);                      % dialog options
        cancelProgVoltageParam = isempty(inputProgVoltageParam);    % cancel dialog

        % Collect input
        voltageStart_cell = inputProgVoltageParam{1};   % starting voltage (cell)
        voltageStart = str2double(voltageStart_cell);   % starting voltage (double)
        voltageEnd_cell = inputProgVoltageParam{2};     % starting voltage (cell)
        voltageEnd = str2double(voltageEnd_cell);       % starting voltage (double)
        stepSize_cell = inputProgVoltageParam{3};       % step size (cell)
        stepSize = str2double(stepSize_cell);           % step size (double)
        timeStep_cell = inputProgVoltageParam{4};       % step size (cell)
        timeStep = str2double(timeStep_cell);           % step size (double)
%         numOfRepeats_cell = inputProgVoltageParam{5}; 	% number of repeats (cell)
%         numOfRepeats = str2double(numOfRepeats_cell);   % number of repeats (double)
        goodStdDev_cell = inputProgVoltageParam{5};     % standard deviations (cell)
        numOfStdDev = str2double(goodStdDev_cell);      % standard deviations 
        if cancelProgVoltageParam == 1                  % cancel detected
            fprintf('\nQuitting...');                    % quitting
            quitProgram = 1;
            return;                                         % exit program
        end

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
                    quitProgram = 1;
                    return;                         % exit program
                otherwise                           % cancel
                    fprintf('Quitting...');     % quitting
                    quitProgram = 1;
                    return;                         % exit program
            end
        end

        % Confirm voltage parameters
        titleQuestProgVoltageParam = 'Confirm Progressive Voltage';
        % Format questions
        voltageStart_use = sprintf('Starting voltage: {\\bf%g V}',voltageStart);% formatted starting voltage
        voltageEnd_use = sprintf('Ending voltage: {\\bf%g V}',voltageEnd);      % formatted ending voltage
        stepSize_use = sprintf('Step size: {\\bf%g V}',stepSize);               % formatted step size
        timeStep_use = sprintf('Time step: {\\bf%g s}',timeStep);           % formatted time step
%         numOfRepeats_use = sprintf('Number of repeats: {\\bf%g}',numOfRepeats);
        numOfStdDev_use = sprintf('Standard deviations: {\\bf%g}',numOfStdDev);

        promptQuestVoltageParam = {...  % question prompt
            voltageStart_use,...        % starting voltage
            voltageEnd_use,...          % ending voltage
            stepSize_use,...            % step size
            timeStep_use,...            % time step
            numOfStdDev_use};

        % Question box
        questVoltageParam = questdlg(...                % question dialog
            promptQuestVoltageParam,...                 % question prompt
            titleQuestProgVoltageParam,...                   % question title
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
            opts);                                      % dialog options
        % Confirmation
        switch questVoltageParam        % apply choice
            case BUTTON_CONFIRM         % check confirmation
                confirmVoltageParam = 1;% confirm parameters
                fprintf('OK.\n');       % parameters confirmed
            case BUTTON_TRY                     % try again
                fprintf('\nTrying again...\n\n'); % starting over
            case BUTTON_CANCEL                  % quit
                fprintf('\nQuitting...');     % quitting
                quitProgram = 1;
                return;                         % exit program
            otherwise                           % cancel
                fprintf('\nQuitting...');     % quitting
                quitProgram = 1;
                return;                         % exit program
        end
    end
catch
    fprintf('\nQuitting...');     % quitting
    voltageStart = 0;
    voltageEnd = 0;
    stepSize = 0;
    timeStep = 0;
    numOfRepeats = 0;
    numOfStdDev = 0;
    quitProgram = 1;
end

end