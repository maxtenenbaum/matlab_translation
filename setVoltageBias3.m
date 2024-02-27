function [] = setVoltageBias3(File,voltageBias)
%% Variables
gpib = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;
channelSelect_len = length(channelSelect);
expID = File.Experiment.ID;

%% Function
% fprintf('Setting voltage bias...\n');

for channel_idx = 1:channelSelect_len
    channelNum = channelSelect(channel_idx);
    [gpibNum,channel] = channelToDeviceChannel(channelNum);
%     if strcmpi(expID,'STEP')
    fprintf('Setting D%dC%d voltage bias...',gpibNum,channel);
    settingBias = sprintf('SOUR%d:VOLT %f',channel,voltageBias);
    writeline(gpib(gpibNum),settingBias);
    fprintf('%g V.\n',voltageBias);
end

end