function [] = setChannelVoltageBias(File,channelNum,voltageBias)
%% Variables
gpib = File.Instrument.Object;

%% Function
fprintf('Setting voltage bias for ');
[gpibNum,channel] = channelToDeviceChannel(channelNum);
fprintf('D%dC%d...',gpibNum,channel);
setBias = sprintf('SOUR%d:VOLT %f',channel,voltageBias);
fprintf(gpib(gpibNum),setBias);
fprintf('%g V.\n',voltageBias);

end