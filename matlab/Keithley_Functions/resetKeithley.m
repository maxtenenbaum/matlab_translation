function [] = resetKeithley(gpib_arr)
%% Constants
MAX_NUM_OF_GPIB = 3;

%% Function
for gpibNum = 1:MAX_NUM_OF_GPIB
    fprintf('Reseting GPIB%02d...',gpibNum);
    try
        fprintf(gpib_arr(gpibNum),'*RST');
    catch
    end
    fprintf('OK.\n');
end

end