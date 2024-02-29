function File = setSourceDelay2(File,state)
%% Constants
OFF = 'OFF';

%% Variables
gpib_arr = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;

%% Function
fprintf('Setting source delay...');

try
    for channelNum = channelSelect
        [gpibNum,channel] = channelToDeviceChannel(channelNum);
        if strcmpi(state,OFF)
            status = 'OFF';
            sourceDelay = sprintf('SOURce%d:DELay:AUTO %s',channel,status);
            writeline(gpib_arr(gpibNum),sourceDelay);
        else
            delay = state;
            if delay > 999.998
                delay = 999.998;
            elseif delay < 0
                delay = 0;
            end
            sourceDelay = sprintf('SOURce%d:DELay: %f',channel,delay);
            writeline(gpib_arr(gpibNum),sourceDelay);
            status = delay;
        end
    end

    File.Instrument.Settings.SourceDelay = status;
    fprintf('%s.\n',status);
catch
end

end