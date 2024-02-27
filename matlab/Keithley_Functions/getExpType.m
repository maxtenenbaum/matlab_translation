function [File,quitProgram] = getExpType(File)
%% Constants
% Code
EXP_LIST = {...
    'Current vs. Time (I-T)',...
    'Current vs. Voltage (I-V)',...
    'Capacitance',...
    'Step Voltage'};
EXP_CODE_LIST = {'IT','IV','CAP','STEP'};
% Button
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';

%% Variables
confirmExpType = false;
quitProgram = false;
expType = [];
expID = [];

%% Function
try
    while confirmExpType == false
        fprintf('Select experiment type...');

        titleExpType = 'Experiment Selection';
        promptExpType = {'Select experiment.'};
        [experimentType_idx,experimentType_tf] = listdlg(...
            'PromptString',promptExpType,...
            'ListString',EXP_LIST,...
            'Name',titleExpType,...
            'SelectionMode','single',...
            'InitialValue',2,...
            'ListSize',[160 60]);

        if ~all(experimentType_tf)   % cancel detected
            fprintf('\nQuitting...'); % quitting
            quitProgram = true;
            return;                     % exit program
        end

        % Collect input
        expType = EXP_LIST{experimentType_idx};
        expID = EXP_CODE_LIST{experimentType_idx};
        % Confirm channel selection
        titleQuestExp = 'Confirm Channel Selection';
        promptQuestExp = sprintf('Experiment type: {\\bf%s}',expType);
        % Question box
        questExp = questdlg(...                      % question dialog
            promptQuestExp,...                       % question prompts
            titleQuestExp,...                        % question title
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
            opts);                                      % dialog options
        % Confirmation
        switch questExp                              % apply choice
            case BUTTON_CONFIRM                         % check confirmation
                confirmExpType = true;               % confirm info
                File.Experiment.Type = expType;
                File.Experiment.ID = expID;
                fprintf('OK.\n');  % info confirmed
            case BUTTON_TRY                             % try again
                confirmExpType = false;               % trying again
                fprintf('\nTrying agin...\n\n');          % starting over
            case BUTTON_CANCEL                          % quit
                fprintf('\nQuitting...');             % quitting
                quitProgram = true;
                return;                                 % exit program
            otherwise                                   % cancel
                fprintf('\nQuitting...');             % quitting
                quitProgram = true;
                return;                                 % exit program
        end
    end
catch
    quitProgram = true;
end

end