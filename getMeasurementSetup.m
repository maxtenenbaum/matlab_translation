function [samplingRate,offsetArray,quitProgram] = getMeasurementSetup(channelSelect,gpib)
%% Constants
NO = 0;
EMPTY = 0;
ONE = 1;
DEFAULT_SPEED = 3;
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
BUTTON_ON = 'ON';
BUTTON_OFF = 'OFF';
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';   % option LaTeX
% Variables
confirmCurrentRange = 0;
confirmAutoZeroMode = 0;
confirmSpeedMode = 0;
confirmRelMode = 0;
currentRange = 0;
autoZeroMode = 0;
speedMode = 0;
quitProgram = 0;

%% Function
% try
    while confirmCurrentRange == NO
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
            'SelectionMode','single');
        
        if currentRange_tf == EMPTY   % cancel detected
            fprintf('\nQuitting...'); % quitting
            quitProgram = 1;
            return;                   % exit program
        end
        
        currentRange_select = listCurrentRange{currentRange_idx};
        currentRange_val = listCurrentRange_val{currentRange_idx};
        
        if currentRange_idx > ONE
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
                confirmCurrentRange = 1;                         % confirm info
%                 fprintf('OK.\n'); % info confirmed
            case BUTTON_TRY                                 % try again
                confirmCurrentRange = 0;                         % trying again
                fprintf('\nTrying agin...\n\n');              % starting over
            case BUTTON_CANCEL                              % quit
                fprintf('\nQuitting...');                 % quitting
                quitProgram = 1;
                return;                                     % exit program
            otherwise                                       % cancel
                fprintf('\nQuitting...');                 % quitting
                quitProgram = 1;
                return;                                     % exit program
        end
    end
    setCurrentRange(channelSelect,gpib,currentRange);       % set current range
    
    while confirmSpeedMode == NO
        % Confirm experiment information
        titleListSpeedMode = 'Speed Mode';
        promptListSpeedMode = 'Select sampling speed mode.';
        
        listSpeedMode = {...
            'Fast (2 Hz)',...
            'Medium (1.5 Hz)',...
            'Normal (1 Hz)',...
            'High Accuracy (0.2 Hz)'};
        
%         listSpeedMode = {...
%             'Fast (5,000 Hz)',...
%             'Medium (500 Hz)',...
%             'Normal (50 Hz)',...
%             'High Accuracy (5 Hz)'};

        listSpeedMode_Val = {...
            'FAST',...
            'MED',...
            'NORM',...
            'HI'};
        
        [speedMode_idx,speedMode_tf] = listdlg(...
            'PromptString',promptListSpeedMode,...
            'ListString',listSpeedMode,...
            'SelectionMode','single',...
            'InitialValue',DEFAULT_SPEED);
        
        if speedMode_tf == EMPTY   % cancel detected
            fprintf('\nQuitting...'); % quitting
            quitProgram = 1;
            return;                   % exit program
        end
        
        speedMode_select = listSpeedMode{speedMode_idx};
        speedMode_val = listSpeedMode_Val{speedMode_idx};
        
        if currentRange_idx > ONE
            speedMode = str2double(speedMode_val);
        else
            speedMode = speedMode_val;
        end
        
        % Format questions
        promptQuestSpeedMode = sprintf('Speed mode: {\\bf%s}',speedMode_select);% inputted speed mode

        % Question box
        questSpeedMode = questdlg(...                   % question dialog
            promptQuestSpeedMode,...                    % question prompts
            titleListSpeedMode,...                      % question title
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
            opts);                                      % dialog options
        % Confirmation
        switch questSpeedMode           % apply choice
            case BUTTON_CONFIRM         % check confirmation
                confirmSpeedMode = 1;   % confirm info
%                 fprintf('OK.\n');       % info confirmed
            case BUTTON_TRY                     % try again
                confirmSpeedMode = 0;           % trying again
                fprintf('\nTrying agin...\n\n');% starting over
            case BUTTON_CANCEL              % quit
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                     % exit program
            otherwise                       % cancel
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                     % exit program
        end
    end
    [samplingRate] = setSpeed(channelSelect,gpib,speedMode);% set speed
    
    while confirmAutoZeroMode == NO
        titleQuestAutoZeroMode = 'Auto-Zero Mode';
        promptQuestAutoZeroMode = {...
            'Select auto-zero mode. {\bfRecommendation: ON}',...
            'Maintains reference of zero current.'};
        autoZeroMode = questdlg(...            % question dialog
            promptQuestAutoZeroMode,...             % question prompts
            titleQuestAutoZeroMode,...              % question litle
            BUTTON_ON,BUTTON_OFF,BUTTON_CANCEL,...  % buttons
            opts);                                  % dialog options
        % Confirmation
        switch autoZeroMode             % apply choice
            case BUTTON_ON              % on
                confirmAutoZeroMode = 1;% setup confirmed
%                 fprintf('OK.\n');       % continue
            case BUTTON_OFF                 % off
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                     % exit program
            case BUTTON_CANCEL              % quit
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                     % exit program
            otherwise                       % cancel
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                     % exit program
        end
    end
    setAutoZero(channelSelect,gpib,autoZeroMode);	% set auto zero
    channelSelect_len = length(channelSelect);
    offsetArray = zeros(channelSelect_len,ONE);
    while confirmRelMode == NO
        titleQuestRelMode = 'Relative Offset Mode';
        promptQuestRelMode = {...
            'Capture relative offset. {\bfRecommendation: ON}',...
            'Captures instrument offset and subtracts from measurement'};
        relMode = questdlg(...            % question dialog
            promptQuestRelMode,...             % question prompts
            titleQuestRelMode,...              % question litle
            BUTTON_ON,BUTTON_OFF,BUTTON_CANCEL,...  % buttons
            opts);                                  % dialog options
        % Confirmation
        switch relMode       	% apply choice
            case BUTTON_ON          % on
                confirmRelMode = 1; % setup confirmed
%                 fprintf('OK.\n');	% continue
%                 [offsetArray] = setRel(channelSelect,gpib,relMode);     % set relative offset
                [offsetArray] = getOffset(channelSelect,gpib,relMode);     % get relative offset
            case BUTTON_OFF                 % off
                confirmRelMode = 1; % setup confirmed
            case BUTTON_CANCEL              % quit
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                     % exit program
            otherwise                       % cancel
                fprintf('\nQuitting...');   % quitting
                quitProgram = 1;
                return;                     % exit program
        end
    end
% catch
%     quitProgram = 1;
% end

end