function [] = setCurrentRange(channelSelect,gpib,state)
%% Constants
MAX_NUM_OF_CHANNEL = 2;
AUTO = 'AUTO';

%% Function
fprintf('Setting current range...');

if isa(state,'char') || isa(state,'string')
    if strcmpi(state,AUTO)
        status = 'AUTO';
        for channelNum = channelSelect
            remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
            gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
            if remainder == 1
                channel = 1;
            else
                channel = 2;
            end
            autoCurrentRange = sprintf('SENSe%d:CURRent:RANGe:AUTO ON',channel);
            fprintf(gpib(gpibNum),autoCurrentRange);
        end
    end
elseif isa(state,'double')
    status = sprintf('%g A',state);
    for channelNum = channelSelect
            remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
            gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
            if remainder == 1
                channel = 1;
            else
                channel = 2;
            end
        currentRange = sprintf('SENSe%d:CURRent:RANGe %e',channel,state);
        fprintf(gpib(gpibNum),currentRange);
    end
end
fprintf('%s.\n',status);

end