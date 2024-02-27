function clearBufferReading(File)
%% Constants
MAX_NUM_OF_GPIB = 6;

%% Variables
gpib = File.Instrument.Object;

%% Function
for gpibNum = 1:MAX_NUM_OF_GPIB
    fprintf(gpib(gpibNum),'TRAce:CLEar');
    fprintf(gpib(gpibNum),'TRACe:CONTrol NEXT');
end

end