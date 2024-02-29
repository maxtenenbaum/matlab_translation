function File = setGroundConnectMode2(File,state)
%% Constants
ON = 'ON';
OFF = 'OFF';

%% Variables
gpib_arr = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;

%% Function
fprintf('Setting ground connect mode...');

if strcmpi(state,ON)
    status = 'ON';
    for channelNum = channelSelect
        [gpibNum,channel] = channelToDeviceChannel(channelNum);
        groundConnectMode = sprintf('SOURce%d:GCONnect %s',channel,status);
        writeline(gpib_arr(gpibNum),groundConnectMode);
    end
elseif strcmpi(state,OFF)
    status = 'OFF';
end

File.Instrument.Settings.GroundConnectMode = status;
fprintf('%s.\n',status);

end