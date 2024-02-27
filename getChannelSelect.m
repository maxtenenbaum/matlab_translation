function [channelSelect,quitProgram] = getChannelSelect()
%% Constants
NO = 0;
EMPTY = 0;
ONE = 1;
FIRST = 1;
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
% Values
MAX_NUM_OF_GPIB = 3;
MAX_NUM_OF_CHANNEL = 2;
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';

%% Variables
totalChannel = MAX_NUM_OF_GPIB * MAX_NUM_OF_CHANNEL;
confirmChannelSelect = 0;
quitProgram = 0;

%% Function
try
    while confirmChannelSelect == NO
        fprintf('Select channels...');
        listChannelSelect = strings(totalChannel,ONE);
        titleChannelSelect = 'Channel Selection';
        
        for channel_idx = FIRST:totalChannel
            remainder = mod(channel_idx,MAX_NUM_OF_CHANNEL);
            gpibNum = ceil(channel_idx/MAX_NUM_OF_CHANNEL);
            if remainder == ONE
                channel = 1;
            else
                channel = 2;
            end
            listChannelSelect(channel_idx) = sprintf('D%dC%d',gpibNum,channel);
        end

        promptChannelSelect = {...
            'Select device and channel to use.',...
            'Hold down CTRL or drag for multi-select'};
        [channelSelect,listChannel_tf] = listdlg(...
            'PromptString',promptChannelSelect,...
            'ListString',listChannelSelect,...
            'Name',titleChannelSelect,...
            'InitialValue',[1 3 4 6]);

        if listChannel_tf == EMPTY   % cancel detected
            fprintf('\nQuitting...'); % quitting
            quitProgram = 1;
            return;                     % exit program
        end

        % Collect input
        channelSelect_len = length(channelSelect);
        promptQuestListCh_list = cell(channelSelect_len,ONE);
        % Confirm channel selection
        titleQuestListCh = 'Confirm Channel Selection';
        % Format questions
        for channelSelect_idx = 1:channelSelect_len
            channel = channelSelect(channelSelect_idx);
            remainder = mod(channel,MAX_NUM_OF_CHANNEL);
            division = channel / MAX_NUM_OF_CHANNEL;
            if remainder == 1
                channelNum = 1;
            else
                channelNum = 2;
            end
            if division <= 1
                gpibNum = 1;
            elseif division <= 2
                gpibNum = 2;
            elseif division <= 3
                gpibNum = 3;
            end
                promptQuestListCh_list{channelSelect_idx} = sprintf('{\\bfD%dC%d}',gpibNum,channelNum);
        end
        promptQuestListCh = vertcat({'Channels selected:'},promptQuestListCh_list);
        % Question box
        questListCh = questdlg(...                      % question dialog
            promptQuestListCh,...                       % question prompts
            titleQuestListCh,...                        % question title
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
            opts);                                      % dialog options
        % Confirmation
        switch questListCh                              % apply choice
            case BUTTON_CONFIRM                         % check confirmation
                confirmChannelSelect = 1;               % confirm info
                fprintf('OK.\n');  % info confirmed
            case BUTTON_TRY                             % try again
                confirmChannelSelect = 0;               % trying again
                fprintf('\nTrying agin...\n\n');          % starting over
            case BUTTON_CANCEL                          % quit
                fprintf('\nQuitting...');             % quitting
                quitProgram = 1;
                return;                                 % exit program
            otherwise                                   % cancel
                fprintf('\nQuitting...');             % quitting
                quitProgram = 1;
                return;                                 % exit program
        end
    end
catch
    channelSelect = 0;
    quitProgram = 1;
end

end