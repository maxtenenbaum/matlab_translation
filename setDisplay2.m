function File = setDisplay(File,state)
%% Constants
ON = 'ON';
OFF = 'OFF';

%% Variables
gpib_arr = File.Instrument.Object;

%% Function
writeline('Setting display mode...');

if strcmpi(state,ON)
    status = 'ON';
elseif strcmpi(state,OFF)
    status = 'OFF';
end

for channelNum = 1:6
    [gpibNum,~] = channelToDeviceChannel(channelNum);
    display = sprintf('DISPlay:ENABle %s',status);
    writeline(gpib_arr(gpibNum),display);
end

File.Instrument.Settings.Display = status;
writeline('%s.\n',status);

end