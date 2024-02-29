function [] = openSaveFolder(savePath)
%% Constants
% Buttons
BUTTON_YES = 'Yes';
BUTTON_NO = 'No';
% Title
TITLE_QUEST_COMPLETE = 'END';
% Prompt
PROMPT_QUEST_COMPLETE = {...
    'PROGRAM ENDED',...
    'Do you want to open your save folder?'};
% Options
opts.Default = 'yes';
opts.Interpreter = 'tex';

%% Function
questComplete = questdlg(...
    PROMPT_QUEST_COMPLETE,...
    TITLE_QUEST_COMPLETE,...
    BUTTON_YES,BUTTON_NO,...
    opts);
switch questComplete
    case BUTTON_YES
        winopen(savePath);
    case BUTTON_NO
    otherwise
end

end