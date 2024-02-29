function File = setDisplay(File,state)
%% Constants
ON = 'ON';
OFF = 'OFF';

%% Variables
gpib_arr = File.Instrument.Object;

%% Function
fprintf('Setting display mode...');

if strcmpi(state,ON)
    status = 'ON';
elseif strcmpi(state,OFF)
    status = 'OFF';
end

for channelNum = 1:12
    [gpibNum,~] = channelToDeviceChannel(channelNum);
    display = sprintf('DISPlay:ENABle %s',status);
    gpib = gpib_arr(gpibNum);
    fprintf(gpib,display);
end

File.Instrument.Settings.Display = status;
fprintf('%s.\n',status);

end