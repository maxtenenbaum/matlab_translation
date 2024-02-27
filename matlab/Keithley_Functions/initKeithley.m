%% Initialize Keithley Connection
function gpib_arr  = initKeithley()
instrreset; %#ok<*INSTRR>
%% Constants
MAX_NUM_OF_GPIB = 3;
% MAX_NUM_OF_CHANNEL = 2;

%% Variables
% gpib_arr = visa.empty(0,MAX_NUM_OF_GPIB);

%% Function
fprintf('Setting up GPIB communication...\n');

for gpibNum = 1:MAX_NUM_OF_GPIB
    resourceName = sprintf('GPIB0::%d::INSTR',gpibNum);
    fprintf('Connecting to GPIB%02d...',gpibNum);
    gpib_arr(gpibNum) = visa('tek',resourceName);           % Connect to GPIB communication
%     try
%         gpib_arr(gpibNum) = visa('tek',resourceName);           % Connect to GPIB communication
% %     gpib_arr(gpibNum) = visadev(resourceName);
%     catch
%         gpib_arr(gpibNum) = visa('ni',resourceName);           % Connect to GPIB communication
%     end
    fprintf('OK.\n');
    fopen(gpib_arr(gpibNum));
end

end