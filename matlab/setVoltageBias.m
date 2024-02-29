function [] = setVoltageBias(channelSelect,gpib_arr,voltageBias)
%% Function
fprintf('Setting voltage bias...');

for channelNum = channelSelect
    [gpibNum,channel] = channelToDeviceChannel(channelNum);
    voltageSourceOn = sprintf('SOURce%d:VOLT %f',channel,voltageBias);
    gpib = gpib_arr(gpibNum);
    fprintf(gpib,voltageSourceOn);
end

fprintf('%g V.\n',voltageBias);

end