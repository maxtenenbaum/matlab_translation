function [] = resetKeithley3(File)
%% Constants
MAX_NUM_OF_GPIB = 3;

%% Variables
gpib_arr = File.Instrument.Object;

%% Function
for gpibNum = 1:MAX_NUM_OF_GPIB
    fprintf('Reseting GPIB%02d...',gpibNum);
    writeline(gpib_arr(gpibNum),'*RST');
    fprintf('OK.\n');
end

end