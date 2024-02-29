function [] = setSource3(File,state)
%% Constants
MAX_NUM_OF_GPIB = 3;    % max number of gpib devices
ONE = 1;
ON = 'ON';
OFF = 'OFF';

%% Variables
gpib = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;
gpibOn = zeros(MAX_NUM_OF_GPIB,ONE);

%% Function
if strcmpi(state,ON)
    fprintf('Setting voltage sources...');
    status = 'ON';
    for channelNum = channelSelect
        [gpibNum,channel] = channelToDeviceChannel(channelNum);
        outputSourceOn = sprintf('OUTPut%d %s',channel,status);
        writeline(gpib(gpibNum),outputSourceOn);
    end

    fprintf('%s.\n',status);
elseif strcmpi(state,OFF)
    fprintf('Setting voltage sources...');
    status = 'OFF';
    for channelNum = channelSelect
        [gpibNum,channel] = channelToDeviceChannel(channelNum);
        if gpibNum == 1
            gpibOn(gpibNum) = gpibOn(1) + 1;
        elseif gpibNum == 2
            gpibOn(gpibNum) = gpibOn(2) + 1;
        elseif gpibNum == 3
            gpibOn(gpibNum) = gpibOn(3) + 1;
        end
        if gpibOn(gpibNum) < 3
            outputSourceOff = sprintf('OUTPut%d %s',channel,status);
            writeline(gpib(gpibNum),outputSourceOff);
        end
    end
    fprintf('%s.\n',status);
end

end