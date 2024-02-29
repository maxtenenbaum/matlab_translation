function [] = setVoltageRange2(File,voltageBias)
%% Constants
% Voltage range
FIXED_10V = 10;
FIXED_30V = 30;

%% Variables
gpib = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;

% Voltage bias
if voltageBias <= FIXED_10V
    voltageRange_num = FIXED_10V;
else
    voltageRange_num = FIXED_30V;
end

%% Function
fprintf('Setting voltage range...');

for channelNum = channelSelect
    [gpibNum,channel] = channelToDeviceChannel(channelNum);
    voltageMode = sprintf('SOURce%d:VOLTage:MODE FIXed',channel);
    fprintf(gpib(gpibNum),voltageMode);
    voltageRange = sprintf('SOURce%d:VOLTage:RANGe %d',channel,voltageRange_num);
    fprintf(gpib(gpibNum),voltageRange);
end

fprintf('%g V.\n',voltageRange_num);

end