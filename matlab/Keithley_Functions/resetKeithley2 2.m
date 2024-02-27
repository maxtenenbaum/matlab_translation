function [] = resetKeithley2(File)
%% Constants
MAX_NUM_OF_GPIB = 6;

%% Variables
gpib_arr = File.Instrument.Object;

%% Function
for gpibNum = 1:MAX_NUM_OF_GPIB
    gpib = gpib_arr(gpibNum);
    fprintf('Reseting GPIB%02d...',gpibNum);
%     fprintf(gpib,':SYSTem:LOCal');
    fprintf(gpib,'*RST');
%     fprintf(gpib,':SYSTem:LOCal');
    fprintf('OK.\n');
%     pause(0.5);
end

end