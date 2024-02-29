function File = setBuffer2(File,state)
%% Constants
ON = 'ON';
OFF = 'OFF';
MAX_NUM_GPIB = 3;

%% Variables
gpib = File.Instrument.Object;
points = 100;

%% Function
bufferSettings = initStruct2('buff');
fprintf('Setting buffer reading...');

if strcmpi(state,ON)
    status = 'ON';
    for gpibNum = 1:MAX_NUM_GPIB
        numOfPoints = sprintf('TRACe:POINts 3000');
        writeline(gpib(gpibNum),numOfPoints);
        writeline(gpib(gpibNum),'TRACe:TSTamp:FORMat DELta');
        trigger = sprintf('TRIGger:COUNt %d',points);
        writeline(gpib(gpibNum),trigger);
        writeline(gpib(gpibNum),'TRAce:CLEar');
        writeline(gpib(gpibNum),'TRACe:CONTrol NEXT');
        writeline(gpib(gpibNum),'INITiate');

%         timeReading = 'FORMat:ELEMents:TRAce TIME';
%         writeline(gpib(gpibNum),timeReading);
%         writeline(gpib(gpibNum),'DATA?');
%         time_str = fscanf(gpib(gpibNum));
%         time = str2double(time_str);
%         rate = 1 / time;
%         disp(time);
        
        bufferSettings.Points = points;
%         bufferSettings.SamplingRate = rate;
        File.Instrument.Settings.Buffer = bufferSettings;
    end
elseif strcmpi(state,OFF)
    status = 'OFF';
end

fprintf('%s.\n',status);

end