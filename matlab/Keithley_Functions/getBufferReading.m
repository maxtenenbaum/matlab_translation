function data_mat = getBufferReading(File)
%% Variables
gpib = File.Instrument.Object;
channelSelect = File.Experiment.Channels;
numOfPoints = File.Instrument.Settings.Buffer.Points;
offset_arr = File.Instrument.Settings.RelativeOffset;
data_mat = [];

%% Function
for channelNum = channelSelect
    [gpibNum,channel] = channelToDeviceChannel(channelNum);
    checkPoints = 'TRACe:POINts:ACTual?';
    fprintf(gpib(gpibNum),checkPoints);
    points_str = fscanf(gpib(gpibNum));
    points = str2double(points_str);
    
    if points == numOfPoints
        bufferReading = sprintf('FORMat:ELEMents:TRAce %d',channel);
        fprintf(gpib(gpibNum),bufferReading);
        fprintf(gpib(gpibNum),'DATA?');
        data_str = fscanf(gpib(gpibNum));
        data = str2double(data_str);
        offset = offset_arr(channelNum);
        data_fix = data - offset;
        data_mat_alloc = [data_mat,data_fix];
        data_mat = data_mat_alloc;
        disp(data_mat);
    end
end

end