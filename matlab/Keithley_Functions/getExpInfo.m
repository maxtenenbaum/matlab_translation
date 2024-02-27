function [subjectName,emailAddress,quitProgram] = getExpInfo()
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
DIMS_DIALOG = [1 50];
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
subjectName = '';
emailAddress = '';
confirmExpInfo = false;
quitProgram = false;

%% Function
% try
    while confirmExpInfo == false
        fprintf('Enter experiment information...');

        % Dialog box
        titleInputExpInfo = 'Experiment Information';   % dialog title
        promptInputExpInfo = {...
            'Subject {\bf(use underscores "\_")}:',...	% subject name
            'Email {\bf(NetID@utdallas.edu)}:'};        % email
        defaultInputExpInfo = {'','@utdallas.edu'};       % input defaults
        inputExpInfo = inputdlg(... % input dialog
            promptInputExpInfo,...  % input prompts
            titleInputExpInfo,...   % input title
            DIMS_DIALOG,...         % dialog dimensions
            defaultInputExpInfo,... % input defaults
            opts);                  % dialog options

        % Collect input
        subjectName = inputExpInfo{1};              % subject name
        emailAddress = inputExpInfo{2};              % subject name
        cancelInputExpInfo = isempty(inputExpInfo); % cancel dialog
        if cancelInputExpInfo == true                  % cancel detected
            fprintf('\nQuitting...');             % quitting
            quitProgram = true;
            return;                                 % exit program
        end

        % Confirm experiment information
        titleQuestExpInfo = 'Confirm Experiment Information';
        % Format questions
        subjectName = inputExpInfo{1};                                      % subject name
        subjectName_fix = strrep(subjectName,'_','\_');                    % fixed subject name
        subjectName_use = sprintf('Subject: {\\bf%s}',subjectName_fix);% formatted subject name
        emailAddress_use = sprintf('Email: {\\bf%s}',emailAddress);  % formatted subject name
        promptQuestExpInfo = {...
            subjectName_use,...                                     % inputted subject name
            emailAddress_use};

        % Question box
        questExpInfo = questdlg(...                     % question dialog
            promptQuestExpInfo,...                      % question prompts
            titleQuestExpInfo,...                       % question title
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
            opts);                                      % dialog options
        % Confirmation
        switch questExpInfo                                 % apply choice
            case BUTTON_CONFIRM                             % check confirmation
                confirmExpInfo = true;                         % confirm info
                fprintf('OK.\n'); % info confirmed
            case BUTTON_TRY                                 % try again
                confirmExpInfo = false;                         % trying again
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
% catch
%     quitProgram = true;
% end

end