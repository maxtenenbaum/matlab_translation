function File = setCurrentRange3(File,currentRange)
%% Constants
AUTO = 'AUTO';
%% Variables
gpib_arr = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;

%% Function
fprintf('Setting current range...');

if isa(currentRange,'char') || isa(currentRange,'string')
    if strcmpi(currentRange,AUTO)
        status = 'AUTO';
        for channelNum = channelSelect
            [gpibNum,channel] = channelToDeviceChannel(channelNum);
            autoCurrentRange = sprintf('SENSe%d:CURRent:RANGe:AUTO ON',channel);
            writeline(gpib_arr(gpibNum),autoCurrentRange);
        end
    end
elseif isa(currentRange,'double')
    status = sprintf('%g A',currentRange);
    for channelNum = channelSelect
            [gpibNum,channel] = channelToDeviceChannel(channelNum);
        currentRange = sprintf('SENSe%d:CURRent:RANGe %e',channel,currentRange);
        writeline(gpib_arr(gpibNum),currentRange);
    end
end

File.Instrument.Settings.CurrentRange = currentRange;
fprintf('%s.\n',status);

end