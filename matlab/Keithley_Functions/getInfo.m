function [File,quitProgram] = getInfo(File)
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
DIMS_DIALOG = [1 50];
% Dialog options
opts.Default = BUTTON_CONFIRM;
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
confirmExpInfo = false;
quitProgram = false;
notebook = '1085';
subjectName = '';
name = 'Last, First';
netID = '';

%% Function
try
    while confirmExpInfo == false
        fprintf('Enter experiment information...');

        % Dialog box
        titleInputExpInfo = 'Experiment Information';   % dialog title
        promptInputExpInfo = {...
            'Notebook',...
            'Subject {\bf(use underscores "\_")}:',...	% subject name
            'Name {\bf(Lastname, Firstname)}:',...
            'NetID:'};        % email
        defaultInputExpInfo = {notebook,subjectName,name,netID};       % input defaults
        inputExpInfo = inputdlg(... % input dialog
            promptInputExpInfo,...  % input prompts
            titleInputExpInfo,...   % input title
            DIMS_DIALOG,...         % dialog dimensions
            defaultInputExpInfo,... % input defaults
            opts);                  % dialog options

        % Collect input
        notebook = inputExpInfo{1};
        subjectName = inputExpInfo{2};              % subject name
        name_raw = inputExpInfo{3};             % name
        if ~contains(name_raw,',')
            name_split = strsplit(name_raw);
            name = [name_split{2} ', ' name_split{1}];
        elseif ~contains(name_raw,', ')
            name_split = strsplit(name_raw,',');
            name = [name_split{1} ', ' name_split{2}];
        else
            name = name_raw;
        end
        netID = inputExpInfo{4};              % subject name
        if isempty(netID)
            emailAddress = '';
        else
            if contains(netID,'@')
                netID_len = length(netID);
                atSign_idx = strfind(netID,'@');
                netID(atSign_idx:netID_len) = [];
            end
            emailAddress = sprintf('%s@utdallas.edu',netID);
        end

        % Confirm experiment information
        titleQuestExpInfo = 'Confirm Experiment Information';
        % Format questions
        notbook_use = sprintf('Notebook: {\\bf%s}',notebook);
        subjectName_fix = strrep(subjectName,'_','\_');                    % fixed subject name
        subjectName_use = sprintf('Subject: {\\bf%s}',subjectName_fix);% formatted subject name
        name_use = sprintf('Name: {\\bf%s}',name);
        netID_use = sprintf('NetID: {\\bf%s}',netID);  % formatted subject name
        promptQuestExpInfo = {...
            notbook_use,...
            subjectName_use,...                                     % inputted subject name
            name_use,...
            netID_use};

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
                File.Notebook = notebook;
                File.Subject = subjectName;
                File.Email = emailAddress;
                File.RecordedBy = name;
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
catch
    quitProgram = true;
end

end