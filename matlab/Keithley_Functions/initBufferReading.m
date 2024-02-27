function initBufferReading(File)
%% Variables
gpib = File.Instrument.Object;
channelSelect = File.Experiment.Channels;

%% Function
for channelNum = channelSelect
    [gpibNum,~] = channelToDeviceChannel(channelNum);
    fprintf(gpib(gpibNum),'TRAce:CLEar');
    fprintf(gpib(gpibNum),'TRACe:CONTrol NEXT');
end

end