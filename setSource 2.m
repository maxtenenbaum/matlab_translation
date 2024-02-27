function [] = setSource(channelSelect,gpib_arr,state)
%% Constants
MAX_NUM_OF_GPIB = 6;    % max number of gpib devices
ON = 'ON';
OFF = 'OFF';

%% Variables
status = upper(state);
gpibOn = zeros(MAX_NUM_OF_GPIB,1);

%% Function
% if strcmpi(state,ON)
%     fprintf('Setting voltage sources...');
%     status = 'ON';
%     for channelNum = channelSelect
%         [gpibNum,channel] = channelToDeviceChannel(channelNum);
%         outputSource_use = sprintf('OUTPut%d %s',channel,status);
%         gpib = gpib_arr(gpibNum);
%         fprintf(gpib,outputSource_use);
%     end
% 
%     fprintf('%s.\n',status);
% elseif strcmpi(state,OFF)
%     fprintf('Setting voltage sources...');
%     status = 'OFF';
%     for channelNum = channelSelect
%         [gpibNum,channel] = channelToDeviceChannel(channelNum);
%         gpibOn(gpibNum) = gpibOn(gpibNum) + 1;
%         if gpibOn(gpibNum) <= 2
%             outputSourceOff = sprintf('OUTPut%d %s',channel,status);
%             gpib = gpib_arr(gpibNum);
%             fprintf(gpib,outputSourceOff);
%         end
%     end
%     fprintf('%s.\n',status);
% end

fprintf('Setting voltage sources...');

for channelNum = channelSelect
    [gpibNum,channel] = channelToDeviceChannel(channelNum);
    outputSource_use = sprintf('OUTPut%d %s',channel,status);
    gpib = gpib_arr(gpibNum);
    fprintf(gpib,outputSource_use);
end

fprintf('%s.\n',status);


end