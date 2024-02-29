function [] = setVoltageRange(voltageBias,channelSelect,gpib)
%% Constants
MAX_NUM_OF_CHANNEL = 2;
% Voltage range
FIXED_10V = 10;
FIXED_30V = 30;

% Variables
if voltageBias <= FIXED_10V
    voltageRange_num = FIXED_10V;
else
    voltageRange_num = FIXED_30V;
end

% Function
fprintf('Setting voltage range...');

for channelNum = channelSelect
    remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
    gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
    if remainder == 1
        channel = 1;
    else
        channel = 2;
    end
    voltageMode = sprintf('SOURce%d:VOLTage:MODE FIXed',channel);
    fprintf(gpib(gpibNum),voltageMode);
    voltageRange = sprintf('SOURce%d:VOLTage:RANGe %d',channel,voltageRange_num);
    fprintf(gpib(gpibNum),voltageRange);
end
fprintf('%g V.\n',voltageRange_num);

end