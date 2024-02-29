function [File,quitProgram] = selectChannels(File)
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
% Values
MAX_NUM_OF_GPIB = 6;
MAX_NUM_OF_CHANNEL = 2;
% Dialog options
opts.Default = BUTTON_CONFIRM;
opts.Interpreter = 'tex';

%% Variables
totalChannel = MAX_NUM_OF_GPIB * MAX_NUM_OF_CHANNEL;
listChannelName = strings(totalChannel,1);
confirmChannelSelect = false;
quitProgram = false;

%% Function
workingChannels = checkChannels();
workingChannels_len = length(workingChannels);
while confirmChannelSelect == false
    fprintf('Select channels...');
    titleChannelSelect = 'Channels Selection';
    for channel_idx = 1:totalChannel
        [gpibNum,channel] = channelToDeviceChannel(channel_idx);
        listChannelName(channel_idx) = sprintf('D%dC%d',gpibNum,channel);
    end
    listChannelName = listChannelName(workingChannels);

    promptChannelSelect = {...
        'Select device and channel to use.',...
        'Hold down CTRL or drag for multi-select.'};
    [channelSelect_idx,listChannel_tf] = listdlg(...
        'PromptString',promptChannelSelect,...
        'ListString',listChannelName,...
        'Name',titleChannelSelect,...
        'InitialValue',1:workingChannels_len,...
        'ListSize',[250 160]);
    channelNameList = listChannelName(channelSelect_idx);
    if ~all(listChannel_tf)   % cancel detected
        fprintf('\nQuitting...'); % quitting
        quitProgram = true;
        return;                     % exit program
    end

    % Collect input
    channelSelect_len = length(channelSelect_idx);
    promptQuestListCh_list = cell(channelSelect_len,1);
    % Confirm channel selection
    titleQuestListCh = 'Confirm Channels Selection';
    % Format questions
    channelSelect = workingChannels(channelSelect_idx);
    for channel_idx = 1:channelSelect_len
        channelNum = channelSelect(channel_idx);
        [gpibNum,channel] = channelToDeviceChannel(channelNum);
        promptQuestListCh_list{channel_idx} = sprintf('{\\bfD%dC%d}',gpibNum,channel);
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
            confirmChannelSelect = true;               % confirm info
            File.Experiment.Channels.Number = channelSelect;
            File.Experiment.Channels.Name = channelNameList;
            fprintf('OK.\n');  % info confirmed
        case BUTTON_TRY                             % try again
            confirmChannelSelect = false;               % trying again
            fprintf('\nTrying agin...\n\n');          % starting over
        case BUTTON_CANCEL                          % quit
            fprintf('\nQuitting...');             % quitting
            quitProgram = true;
            return;                                 % exit program
        otherwise                                   % cancel
            fprintf('\nQuitting...');             % quitting
            quitProgram = true;
            return;                                 % exit program
    end
end

end