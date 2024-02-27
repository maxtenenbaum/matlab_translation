function [] = setSource2(File,state)
%% Constants
MAX_NUM_OF_GPIB = 6;    % max number of gpib devices
ON = 'ON';
OFF = 'OFF';

%% Variables
gpib = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;
gpibOn = zeros(MAX_NUM_OF_GPIB,1);

%% Function
% if strcmpi(state,ON)
%     fprintf('Setting voltage sources...');
%     status = 'ON';
%     for channelNum = channelSelect
%         [gpibNum,channel] = channelToDeviceChannel(channelNum);
%         outputSourceOn = sprintf('OUTPut%d %s',channel,status);
%         fprintf(gpib(gpibNum),outputSourceOn);
%     end
% 
%     fprintf('%s\n',status);
% elseif strcmpi(state,OFF)
%     fprintf('Setting voltage sources...');
%     status = 'OFF';
%     for channelNum = channelSelect
%         [gpibNum,channel] = channelToDeviceChannel(channelNum);
%         gpibOn(gpibNum) = gpibOn(gpibNum) + 1;
%         if gpibOn(gpibNum) <= 2
%             outputSourceOff = sprintf('OUTPut%d %s',channel,status);
%             fprintf(gpib(gpibNum),outputSourceOff);
%         end
%     end
%     fprintf('%s\n',status);
% end

fprintf('Setting voltage sources...');
for channelNum = channelSelect
    [gpibNum,channel] = channelToDeviceChannel(channelNum);
    outputSourceOn = sprintf('OUTPut%d %s',channel,state);
    fprintf(gpib(gpibNum),outputSourceOn);
end

fprintf('%s\n',state);



end