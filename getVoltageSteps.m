function [voltageStepCycle,quitProgram] = getVoltageSteps(lowerLimit,upperLimit,voltageStart,stepSize,numOfCycles)
%% Constants
% Values
ONE = 1;
FIRST = 1;
SECOND = 2;
% Buttons
BUTTON_CONFIRM = 'Confirm'; % confirm button
BUTTON_TRY = 'Start Over';  % start over button
BUTTON_CANCEL = 'Cancel';   % cancel button
% Titles
TITLE_ERROR = 'ERROR';
% Options
opts.Default = 'yes';       % option dedault
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
% Voltage steps list
stepSize_sign = sign(stepSize);
stepSize_mag = abs(stepSize);
listVoltageSteps = lowerLimit:stepSize_mag:upperLimit;
if stepSize_sign == -1
    listVoltageSteps = flip(listVoltageSteps);
end
% voltageRange_len = length(listVoltageSteps);
% voltageStart_idx = find(listVoltageSteps == voltageStart);
listVoltageSteps_len = length(listVoltageSteps);
promptQuestVoltageSteps = strings(listVoltageSteps_len,ONE);
listNumOfSteps = ONE:listVoltageSteps_len;
for step = listNumOfSteps
    promptQuestVoltageSteps(step) = sprintf('%g',listVoltageSteps(step));
end
promptQuestListVoltageSteps_str = cellstr(promptQuestVoltageSteps);
% Checks
confirmVoltageSteps = 0;
voltageStepCycle = 0;
quitProgram = 0;

%% Function
fprintf('Select voltage steps...');
try
    while confirmVoltageSteps == 0
        confirmStart = 0;
        while confirmStart == 0
            % Dialog box
            titleListVoltageSteps = 'Voltage Step Selection';       % list title
            promptListVoltageSteps = {...                           % list prompts
                'Select voltage steps to apply.',...                % insrtuction
                'Hold CTRL for multi-select.'};                     % multi-select
            [voltageSteps_select,listVolageSteps_tf] = listdlg(...	% list dialog
                'PromptString',promptListVoltageSteps,...           % list prompts
                'ListString',promptQuestListVoltageSteps_str,...    % list
                'Name',titleListVoltageSteps,...                    % list title
                'InitialValue',listNumOfSteps);                     % starting voltage
            
            % Collect input
            numOfVoltageSteps = length(voltageSteps_select);
            if listVolageSteps_tf == 0          % cancel detected
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                         % exit program
            end
            listVoltageSteps_select = listVoltageSteps(voltageSteps_select);
            voltageStart_select = find(listVoltageSteps_select == voltageStart,FIRST);
            if isempty(voltageStart_select)
                prompt1 = 'STARTING VOLTAGE NOT SELECTED!';
                disp(prompt1);
                prompt2 = 'Please include starting voltage.';
                prompt = {prompt1,prompt2};
                start = questdlg(prompt,TITLE_ERROR,BUTTON_TRY,BUTTON_CANCEL,opts);
                switch start
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
            else
                confirmStart = 1;
            end
        end

        % Confirm voltage steps selection
        titleQuestVoltageSteps = 'Confirm Voltage Step Selection';
        % Format questions
        promptQuestVoltageSteps = sprintf('Voltage steps selected:');
        cellLength = numOfVoltageSteps + ONE;
        promptQuestVoltageSteps_cell = {cellLength,ONE};
        promptQuestVoltageSteps_cell{1} = promptQuestVoltageSteps;
        for voltageSteps_idx = 1:numOfVoltageSteps
            voltageSteps = listVoltageSteps(voltageSteps_select(voltageSteps_idx));
            voltageSteps_str = sprintf('{\\bf%g}',voltageSteps);
            voltageSteps_cell = voltageSteps_idx + ONE;
            promptQuestVoltageSteps_cell{voltageSteps_cell} = voltageSteps_str;
        end
        % Question box
        questVoltageSteps = questdlg(...                % question dialog
            promptQuestVoltageSteps_cell,...         	% question prompts
            titleQuestVoltageSteps,...                  % question title
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
            opts);                                      % dialog options
        % Confirmation
        switch questVoltageSteps                % apply choice
            case BUTTON_CONFIRM                 % check confirmation
                confirmVoltageSteps = 1;        % confirm info
                fprintf('OK.\n');             % info confirmed
            case BUTTON_TRY                     % try again
                fprintf('\nTrying agin...\n\n');% starting over
            case BUTTON_CANCEL                  % quit
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                         % exit program
            otherwise                           % cancel
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                         % exit program
        end
    end

    % Voltage step cycle
    % forward
    voltageStepForward_idx = voltageSteps_select(voltageStart_select:end);
    % reverse
    voltageStep_select_flip = flip(voltageSteps_select);
    voltageStepReverse_idx = voltageStep_select_flip(SECOND:end);
    % return
    % voltageStepReturn_idx_end = voltageStart_select - ONE;
    % voltageStepReturn_idx = voltageSteps_select(SECOND:voltageStepReturn_idx_end);
    voltageStepReturn_idx = voltageSteps_select(SECOND:voltageStart_select);
    voltageStepCycle_idx = [voltageStepForward_idx,voltageStepReverse_idx,voltageStepReturn_idx];
    % cycle
    if numOfCycles == ONE
        voltageStepCycle = listVoltageSteps(voltageStepCycle_idx);
    else
        voltageStepCycle_idx_fix = voltageStepCycle_idx(SECOND:end);
        voltageStepCycle_idx_full = [];
        for cycle = FIRST:numOfCycles
            if cycle == FIRST
                voltageStepCycle_idx_full_alloc = [voltageStepCycle_idx_full,voltageStepCycle_idx];
            else
                voltageStepCycle_idx_full_alloc = [voltageStepCycle_idx_full,voltageStepCycle_idx_fix];
            end
            voltageStepCycle_idx_full = voltageStepCycle_idx_full_alloc;
        end
        voltageStepCycle = listVoltageSteps(voltageStepCycle_idx_full);
    end
catch
    voltageStepCycle = 0;
    quitProgram = 1;
end

end