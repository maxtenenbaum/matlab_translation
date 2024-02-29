function [] = setGroundConnectMode(channelSelect,gpib,state)
%% Constants
MAX_NUM_OF_CHANNEL = 2;
ON = 'ON';
OFF = 'OFF';

%% Function
fprintf('Setting ground connect mode...');

if strcmpi(state,ON)
    status = 'ON';
    for channelNum = channelSelect
        remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
        gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
        if remainder == 1
            channel = 1;
        else
            channel = 2;
        end
        groundConnectMode = sprintf('SOURce%d:GCONnect %s',channel,status);
        fprintf(gpib(gpibNum),groundConnectMode);

    end
elseif strcmpi(state,OFF)
    status = 'OFF';
end
    
fprintf('%s.\n',status);

end