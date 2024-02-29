function [File,quitProgram] = selectRelMode(File)
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_ON = 'ON';
BUTTON_OFF = 'OFF';
% Dialog options
opts.Default = BUTTON_ON;
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
confirmRelMode = false;
quitProgram = false;

%% Function
while confirmRelMode == false
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
            confirmRelMode = true; % setup confirmed
            File = getOffset2(File,relMode);     % get relative offset
        case BUTTON_OFF                 % off
            confirmRelMode = true; % setup confirmed
            File = getOffset2(File,relMode);     % get relative offset
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