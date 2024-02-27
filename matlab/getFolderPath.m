function [folderPath,quitProgram] = getFolderPath()
%% Constants
% Buttons
BUTTON_CONFIRM = 'Confirm'; % confirm button
BUTTON_TRY = 'Start Over';  % start over button
BUTTON_CANCEL = 'Cancel';   % cancel button
% Options
opts.Default = BUTTON_CONFIRM;       % option dedault
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
confirmFolderPath = 0;
quitProgram = 0;

%% Function
while confirmFolderPath == 0
    fprintf('Select folder path...');
    
    % Input save path
    titleMsgFolderPath = 'Folder Path';                             % message title
    promptMsgtFolderPath = 'Press OK to select folder.';   % message prompt
    waitfor(msgbox(promptMsgtFolderPath,titleMsgFolderPath));       % message box
    folderPath = uigetdir('','Folder Folder');                      % input folder folder
    if folderPath == 0                        % cancel detected
        fprintf('\nQuitting...');         % quitting
        quitProgram = 1;
        return;                             % exit program
    end

    % Confirm folder path
    titleQuestFolderPath = 'Confirm Folder Path';   % question title
    promptQuestFolderPath1 = 'Folder path:';        % message
    promptQuestFolderPath2 = folderPath;            % inputted folder path
    
    % Question box
    questFolderPath = questdlg(...                    % question dialog
        {promptQuestFolderPath1,...                   % question prompt 1
        promptQuestFolderPath2},...                   % question prompt 2
        titleQuestFolderPath,...                      % question title
        BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
        opts);                                      % dialog options
    
    % Confirmation
    switch questFolderPath                    % apply choice
        case BUTTON_CONFIRM                 % check confirmation
            confirmFolderPath = 1;            % confirm path
            fprintf('OK\n\n');             % path confirmed
        case BUTTON_TRY                     % try again
            confirmFolderPath = 0;            % trying again
            fprintf('\nTrying again...\n\n'); % starting over
        case BUTTON_CANCEL                  % quit
            fprintf('\nQuitting...');     % quitting
            quitProgram = 1;
            return;                         % exit program
        otherwise                           % cancel
            fprintf('\nQuitting...\');     % quitting
            quitProgram = 1;
            return;                         % exit program
    end
end

end