function File = setBuffer(File,state)
%% Constants
ON = 'ON';
OFF = 'OFF';
MAX_NUM_OF_GPIB = 6;

%% Variables
gpib_arr = File.Instrument.Object;
numOfPoints = 1;

%% Function
bufferSettings = initStruct2('buff');
fprintf('\tSetting buffer reading...');

if strcmpi(state,ON)
    status = 'ON';
    for gpibNum = 1:MAX_NUM_OF_GPIB
        gpib = gpib_arr(gpibNum);
        fprintf(gpib,'TRACe:CLEar');
        numOfPoints_use = sprintf('TRACe:POINts %d',numOfPoints);
        fprintf(gpib,numOfPoints_use);
        fprintf(gpib,'TRACe:TSTamp:FORMat DELta');
        fprintf(gpib,'TRACe:FEED:CONTrol NEXT');
        fprintf(gpib,'INITiate');

%         timeReading = 'FORMat:ELEMents:TRAce TIME';
%         fprintf(gpib(gpibNum),timeReading);
%         fprintf(gpib(gpibNum),'DATA?');
%         time_str = fscanf(gpib(gpibNum));
%         time = str2double(time_str);
%         rate = 1 / time;
%         disp(time);
        
        bufferSettings.Points = numOfPoints;
%         bufferSettings.SamplingRate = rate;
        
    end
elseif strcmpi(state,OFF)
    status = 'OFF';
    bufferSettings.Points = 0;
end
File.Instrument.Settings.Buffer = bufferSettings;

fprintf('%s\n',status);

end