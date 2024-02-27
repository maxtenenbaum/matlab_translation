function File = setPowerLine(File,freq)
%% Variables
gpib_arr = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;

if freq <= 50
    freq = 50;
else
    freq = 60;
end

%% Function
fprintf('Setting power line frequency...');

for channelNum = channelSelect
    [gpibNum,~] = channelToDeviceChannel(channelNum);
    powerLine = sprintf('SYSTem:LFRequency %d',freq);
    gpib = gpib_arr(gpibNum);
    fprintf(gpib,powerLine);
end
File.Instrument.Settings.PowerLine = 60;
fprintf('%d Hz\n',freq);

end