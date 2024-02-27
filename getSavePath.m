function [savePath,quitProgram] = getSavePath()
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';

%% Variables
confirmSavePath = 0;
quitProgram = 0;

%% Function
try
    while confirmSavePath == 0
        fprintf('Enter save path...');

        % Input save path
        titleMsgSavePath = 'Save Path';                             % message title
        promptMsgtSavePath = 'Press OK to select a save folder.';   % message prompt
        waitfor(msgbox(promptMsgtSavePath,titleMsgSavePath));       % message box
        savePath = uigetdir('','Save Folder');                      % input save folder
        if savePath == 0                        % cancel detected
            fprintf('\nQuitting...');         % quitting
            quitProgram = 1;
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
                confirmSavePath = 1;                            % confirm path
%                 fprintf('OK.\n');
                fprintf('%s\n',savePath); % path confirmed
            case BUTTON_TRY                                     % try again
                confirmSavePath = 0;                            % trying again
                fprintf('\nTrying again...\n\n');                 % starting over
            case BUTTON_CANCEL                                  % quit
                fprintf('\nQuitting...');                     % quitting
                quitProgram = 1;
                return;                                         % exit program
            otherwise                                           % cancel
                fprintf('\nQuitting...');                     % quitting
                quitProgram = 1;
                return;                                         % exit program
        end
    end
catch
    savePath = 0;
    quitProgram = 1;
end

end