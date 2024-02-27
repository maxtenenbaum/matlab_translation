%% Initialize Keithley Connection
function File = initKeithley3(File)
%% Constants
MAX_NUM_OF_GPIB = 3;
% MAX_NUM_OF_CHANNEL = 2;

%% Variables
% gpibOn = zeros(MAX_NUM_OF_GPIB,1);
gpib_arr = visalib.GPIB.empty(0,MAX_NUM_OF_GPIB);
% resourceName_list = strings(3,1);

%% Function
fprintf('Setting up GPIB communication...\n');

for gpibNum = 1:MAX_NUM_OF_GPIB
    resourceName = sprintf('GPIB0::%d::INSTR',gpibNum);
%     resourceName_list(gpibNum) = resourceName;
    fprintf('Connecting to GPIB%02d...',gpibNum);
    device = visadev(resourceName);
    gpib_arr(gpibNum) = device;           % Connect to GPIB communication
    fprintf('OK.\n');
%     File.Instrument.Resource(gpibNum).Name = device.Name;
end
% File.Instrument.Resource = resourceName_list;
File.Instrument.Object = gpib_arr;
% resetKeithley3(File);

end