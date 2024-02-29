function File = setAutoZero2(File,state)
%% Constants
ON = 'ON';
OFF = 'OFF';

%% Variables
gpib_arr = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;

%% Function
fprintf('Setting auto zero...');

if strcmpi(state,ON)
    status = 'ON';
    for channelNum = channelSelect
    [gpibNum,~] = channelToDeviceChannel(channelNum);
        autoZero = sprintf('SYSTem:AZERo:STATe %s',status);
        gpib = gpib_arr(gpibNum);
        fprintf(gpib,autoZero);
    end
elseif strcmpi(state,OFF)
    status = 'OFF';
end

File.Instrument.Settings.AutoZero = status;
fprintf('%s.\n',status);

end