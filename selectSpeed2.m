function [File,quitProgram] = selectSpeed2(File)
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
confirmSpeed = false;
quitProgram = false;

%% Function
while confirmSpeed == false
    % Confirm experiment information
    titleListSpeedMode = 'Speed Mode';
    promptListSpeedMode = {...
        'Select sampling speed mode.',...
        '"NPLC" is the number of power-line cycles per integration',...
        'Time shown is integration time per reading.'};

    listSpeedMode = {...
        'Fast (166.67 μs)',...
        'Medium (1.67 ms)',...
        'Normal (16.67 ms)',...
        'High Accuracy (166.67 ms)'};

    listSpeedMode_Val = {...
        'FAST',...
        'MED',...
        'NORM',...
        'HI'};

    [speedMode_idx,speedMode_tf] = listdlg(...
        'PromptString',promptListSpeedMode,...
        'ListString',listSpeedMode,...
        'SelectionMode','single',...
        'InitialValue',1,...
        'ListSize',[160 70]);

    if ~all(speedMode_tf)   % cancel detected
        fprintf('\nQuitting...'); % quitting
        quitProgram = true;
        return;                   % exit program
    end

    speed_select = listSpeedMode{speedMode_idx};
    speed = listSpeedMode_Val{speedMode_idx};

%     if currentRange_idx > 1
%         speed = str2double(speed_val);
%     else
%         speed = speed_val;
%     end

    % Format questions
    promptQuestSpeedMode = sprintf('Speed mode: {\\bf%s}',speed_select);% inputted speed mode

    % Question box
    questSpeedMode = questdlg(...                   % question dialog
        promptQuestSpeedMode,...                    % question prompts
        titleListSpeedMode,...                      % question title
        BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
        opts);                                      % dialog options
    % Confirmation
    switch questSpeedMode           % apply choice
        case BUTTON_CONFIRM         % check confirmation
            confirmSpeed = true;   % confirm info
            File = setSpeed3(File,speed); % set speed
            %                 fprintf('OK.\n');       % info confirmed
        case BUTTON_TRY                     % try again
            confirmSpeed = false;           % trying again
            fprintf('\nTrying agin...\n\n');% starting over
        case BUTTON_CANCEL              % quit
            fprintf('\nQuitting...');   % quitting
            quitProgram = true;
            return;                     % exit program
        otherwise                       % cancel
            fprintf('\nQuitting...');   % quitting
            quitProgram = true;
            return;                     % exit program
    end
end

end