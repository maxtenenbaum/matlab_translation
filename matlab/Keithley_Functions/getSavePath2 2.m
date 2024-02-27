function [File,quitProgram] = getSavePath2(File)
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
% Dialog options
opts.Default = BUTTON_CONFIRM;
opts.Interpreter = 'tex';

%% Variables
confirmSavePath = false;
quitProgram = false;

%% Function
while confirmSavePath == false
    fprintf('Enter save path...');

    % Input save path
    titleMsgSavePath = 'Save Path';                             % message title
    promptMsgtSavePath = 'Press OK to select a save folder.';   % message prompt
    waitfor(msgbox(promptMsgtSavePath,titleMsgSavePath));       % message box
    savePath = uigetdir('','Save Folder');                      % input save folder
    if savePath == false                        % cancel detected
        fprintf('\nQuitting...');         % quitting
        quitProgram = true;
        return;                             % exit program
    end

    % Confirm save path
    titleQuestSavePath = 'Confirm Save Path';   % question title
    promptQuestSavePath1 = 'Save path:';        % message
    promptQuestSavePath2 = savePath;            % inputted save path

    % Question box
    questSavePath = questdlg(...                    % question dialog
        {promptQuestSavePath1,...                   % question prompt 1
        promptQuestSavePath2},...                   % question prompt 2
        titleQuestSavePath,...                      % question title
        BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
        opts);                                      % dialog options

    % Confirmation
    switch questSavePath                                    % apply choice
        case BUTTON_CONFIRM                                 % check confirmation
            confirmSavePath = true;                            % confirm path
            File.Path = savePath;
            fprintf('"%s"\n',savePath); % path confirmed
        case BUTTON_TRY                                     % try again
            confirmSavePath = false;                            % trying again
            fprintf('\nTrying again...\n\n');                 % starting over
        case BUTTON_CANCEL                                  % quit
            fprintf('\nQuitting...');                     % quitting
            quitProgram = true;
            return;                                         % exit program
        otherwise                                           % cancel
            fprintf('\nQuitting...');                     % quitting
            quitProgram = true;
            return;                                         % exit program
    end
end

end