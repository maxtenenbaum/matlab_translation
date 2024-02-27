function data_mat = getBufferReading2(File)
%% Constants
MAX_NUM_GPIB = 3;
%% Variables
gpib = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;
numOfPoints = File.Instrument.Settings.Buffer.Points;
offset_arr = File.Instrument.Settings.RelativeOffset;
data_mat = {};
isBufferFull = false;

%% Function
while ~isBufferFull

for channelNum = channelSelect
    [gpibNum,channel] = channelToDeviceChannel(channelNum);
    fprintf(gpib(gpibNum),'TRACe:FREE?');
    byts_str = fscanf(gpib(gpibNum));
    bytes = str2double(byts_str);
    fprintf(gpib(gpibNum),'TRACe:POINts:ACTual?');
    points_str = fscanf(gpib(gpibNum));
    points = str2double(points_str);
    fprintf('%d points, %d bytes left \n',points,bytes);

    if points == numOfPoints
        isBufferFull = true;
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

        for gpibNum = 1:MAX_NUM_GPIB
            fprintf(gpib(gpibNum),'TRACe:CONTrol NEXT');
        end
    end
end

end

end