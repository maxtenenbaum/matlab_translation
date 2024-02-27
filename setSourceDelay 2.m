function File = setSourceDelay(File,state)
%% Constants
OFF = 'OFF';

%% Variables
gpib_arr = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;

%% Function
fprintf('Setting source delay...');

for channelNum = channelSelect
    [gpibNum,channel] = channelToDeviceChannel(channelNum);
    gpib = gpib_arr(gpibNum);
    if strcmpi(state,OFF)
        status = 'OFF';
        sourceDelay = sprintf('SOURce%d:DELay:AUTO %s',channel,status);
        fprintf(gpib,sourceDelay);
    else
        delay = state;
        if delay > 999.998
            delay = 999.998;
        elseif delay < 0
            delay = 0;
        end
        status = delay;
        sourceDelay = sprintf('SOURce%d:DELay: %f',channel,delay);
    end
    fprintf(gpib,sourceDelay);
end

File.Instrument.Settings.SourceDelay = status;
fprintf('%s.\n',status);

end