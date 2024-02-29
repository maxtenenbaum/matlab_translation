function [File,quitProgram] = selectAutoZero2(File)
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_ON = 'ON';
BUTTON_OFF = 'OFF';
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
confirmAutoZero = false;
quitProgram = false;

%% Function
while confirmAutoZero == false
    titleQuestAutoZeroMode = 'Auto-Zero Mode';
    promptQuestAutoZeroMode = {...
        'Select auto-zero mode. {\bfRecommendation: ON}',...
        'Maintains reference of zero current.'};
    autoZero = questdlg(...            % question dialog
        promptQuestAutoZeroMode,...             % question prompts
        titleQuestAutoZeroMode,...              % question litle
        BUTTON_ON,BUTTON_OFF,BUTTON_CANCEL,...  % buttons
        opts);                                  % dialog options
    % Confirmation
    switch autoZero             % apply choice
        case BUTTON_ON              % on
            confirmAutoZero = true;% setup confirmed
            File = setAutoZero3(File,autoZero);	% set auto zero
            %                 fprintf('OK.\n');       % continue
        case BUTTON_OFF                 % off
            fprintf('\nQuitting...');   % quitting
            quitProgram = true;
            return;                     % exit program
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