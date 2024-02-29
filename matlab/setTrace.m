function [] = setTrace(channelSelect,gpib,state)
%% Constants
MAX_NUM_OF_CHANNEL = 2;
ON = 'ON';
OFF = 'OFF';

%% Function
fprintf('Setting trace...');

if strcmpi(state,OFF)
    status = 'OFF';
    for channelNum = channelSelect
    %     remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
        gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
    %     if remainder == 1
    %         channel = 1;
    %     else
    %         channel = 2;
    %     end
        buffer = sprintf('TRACe:FEED:CONTrol NEVer');
        fprintf(gpib(gpibNum),buffer);
    end
elseif strcmpi(state,ON)
    status = 'ON';
end

fprintf('%s.\n',status);

end