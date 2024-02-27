%% Disconnect with Keithley
function [] = closeKeithley2(File)
%% Constants
MAX_NUM_OF_GPIB = 3;    % max number of gpib devices
MAX_NUM_OF_CHANNEL = 2;
ONE = 1;

%% Variables
gpib = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;
gpibOn = zeros(MAX_NUM_OF_GPIB,ONE);

%% Function
fprintf('Disconnecting GPIB devices...');

for channelNum = channelSelect
    gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
    if gpibNum == 1
        gpibOn(gpibNum) = gpibOn(1) + 1;
    elseif gpibNum == 2
        gpibOn(gpibNum) = gpibOn(2) + 1;
    elseif gpibNum == 3
        gpibOn(gpibNum) = gpibOn(3) + 1;
    end
    if gpibOn(gpibNum) == 1
        fclose(gpib(gpibNum));
        delete(gpib(gpibNum));
    end
end
fprintf('OK.\n');

end