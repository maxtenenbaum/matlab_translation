function File = setCurrentRange2(File,currentRange)
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
            gpib = gpib_arr(gpibNum);
            fprintf(gpib,autoCurrentRange);
        end
    end
elseif isa(currentRange,'double')
    status = sprintf('%g A',currentRange);
    for channelNum = channelSelect
        [gpibNum,channel] = channelToDeviceChannel(channelNum);
        currentRange = sprintf('SENSe%d:CURRent:RANGe %e',channel,currentRange);
        gpib = gpib_arr(gpibNum);
        fprintf(gpib,currentRange);
    end
end

File.Instrument.Settings.CurrentRange = currentRange;
fprintf('%s.\n',status);

end