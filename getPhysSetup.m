%% Check physical setup
function [quitProgram] = getPhysSetup()
%% Constants
% Dialog
BUTTON_YES = 'Yes';
BUTTON_NO = 'No';
BUTTON_OK = 'OK';
BUTTON_QUIT = 'Quit';
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';

%% Variables
confirmPhysSetup = 0;
quitProgram = 0;

%% Function
while confirmPhysSetup == 0                 % check setup
    fprintf('Checking physical setup...');  % checking setup
    % Notice
    promptNotice = {...
        'This code ONLY works for:',...
        '\bullet Keithley Model 6482 Dual-Channel Picoammeter/Voltage Source',...
        '\bullet Applying the same voltage bias for all devices and channels'};
    titleNotice = 'NOTICE';
    notice = questdlg(promptNotice,titleNotice,BUTTON_OK,BUTTON_QUIT,opts);
    switch notice
        case BUTTON_OK
        case BUTTON_QUIT                % quit
            fprintf('\nQuitting...');	% quitting
            quitProgram = 1;
            return;                     % exit program
        otherwise                       % cancel
            fprintf('\nQuitting...');   % quitting
            quitProgram = 1;
            return;                     % exit program
    end

    % Check
    titleQuestCheck = 'Check';
    promptQuestCheck_list = {...
        'Do all connectors have proper isolated contact with electrodes?',...
        'Are all black cables disconnected from ground?',...
        'Are all equipement turned on?'};
    numOfQuestCheck = length(promptQuestCheck_list);% number of questions
    for quest = 1:numOfQuestCheck                       % loop through questions
        promptQuestCheck = promptQuestCheck_list{quest};
        questCheck = questdlg(...               % question dialog
            promptQuestCheck,...                % question prompts
            titleQuestCheck,...                 % question litle
            BUTTON_YES,BUTTON_NO,BUTTON_QUIT,...% buttons
            opts);                              % dialog options
        % Confirmation
        titleError = 'ERROR';
        switch questCheck                   % apply choice
            case BUTTON_YES                 % check
                if quest == numOfQuestCheck	% completed checks
                    confirmPhysSetup = 1;   % setup confirmed
                    fprintf('OK.\n');     % continue
                end
            case BUTTON_NO                                  % bad answer
                promptConfirm = {...
                    'SETUP INCOMPLETE',...                  % setup incomplete
                    'Answer MUST be "Yes" to continue!'};   % solution
                waitfor(msgbox(promptConfirm,titleError));  % message
                fprintf('\nQuitting...');                   % quitting
                quitProgram = 1;
                return;                                     % exit program
            case BUTTON_QUIT                % quit
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                     % exit program
            otherwise                       % cancel
                fprintf('\nQuitting...'); % quitting
                quitProgram = 1;
                return;                     % exit program
        end
    end
end

end