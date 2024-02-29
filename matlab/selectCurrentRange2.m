function [File,quitProgram] = selectCurrentRange2(File)
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
confirmCurrentRange = false;
quitProgram = false;

%% Function
while confirmCurrentRange == false
    fprintf('Enter measurement setup...\n');

    % Confirm experiment information
    titleListCurrentRange = 'Current Range';
    promptListCurrentRange = {'Select current range.'};
    listCurrentRange = {...
        'AUTO',...
        '2 nA',...
        '20 nA',...
        '200 nA',...
        '2 uA',...
        '20 uA',...
        '200 uA',...
        '2 mA',...
        '20 mA'};

    listCurrentRange_val = {...
        'AUTO',...
        '2e-9',...
        '2e-8',...
        '2e-7',...
        '2e-6',...
        '2e-5',...
        '2e-4',...
        '2e-3',...
        '2e-2'};

    [currentRange_idx,currentRange_tf] = listdlg(...
        'PromptString',promptListCurrentRange,...
        'ListString',listCurrentRange,...
        'SelectionMode','single',...
        'ListSize',[160 120]);

    if ~all(currentRange_tf)   % cancel detected
        fprintf('\nQuitting...'); % quitting
        quitProgram = true;
        return;                   % exit program
    end

    currentRange_select = listCurrentRange{currentRange_idx};
    currentRange_val = listCurrentRange_val{currentRange_idx};

    if currentRange_idx > 1
        currentRange = str2double(currentRange_val);
    else
        currentRange = currentRange_val;
    end
    % Format questions
    promptQuestCurrentRange = sprintf('Current range: {\\bf%s}',currentRange_select);% inputted current range

    % Question box
    questCurrentRange = questdlg(...                     % question dialog
        promptQuestCurrentRange,...                      % question prompts
        titleListCurrentRange,...                       % question title
        BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
        opts);                                      % dialog options
    % Confirmation
    switch questCurrentRange                                 % apply choice
        case BUTTON_CONFIRM                             % check confirmation
            confirmCurrentRange = true;                         % confirm info
            File = setCurrentRange3(File,currentRange);       % set current range
            %                 fprintf('OK.\n'); % info confirmed
        case BUTTON_TRY                                 % try again
            confirmCurrentRange = false;                         % trying again
            fprintf('\nTrying agin...\n\n');              % starting over
        case BUTTON_CANCEL                              % quit
            fprintf('\nQuitting...');                 % quitting
            quitProgram = true;
            return;                                     % exit program
        otherwise                                       % cancel
            fprintf('\nQuitting...');                 % quitting
            quitProgram = true;
            return;                                     % exit program
    end
end

end