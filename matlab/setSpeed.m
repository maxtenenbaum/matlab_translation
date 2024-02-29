function [samplingRate] = setSpeed(channelSelect,gpib,state)
%% Constants
MAX_NUM_OF_CHANNEL = 2;
FAST = 'FAST';
MED = 'MED';
NORM = 'NORM';
DEF = 'DEF';
HI = 'HI';
MAX_SPEED = 10;
POWER_LINE = 60;
MIN_SPEED = 0.01;

%% Function
fprintf('Setting speed...');
if isa(state,'char') || isa(state,'string')
    if contains(state,FAST,'IgnoreCase',true)
        status = 'FAST';
        powerLineCycle = 0.01;
    elseif contains(state,MED,'IgnoreCase',true)
        status = 'MEDIUM';
        powerLineCycle = 0.1;
    elseif contains(state,NORM,'IgnoreCase',true) || contains(state,DEF,'IgnoreCase',true)
        status = 'NORMAL';
        powerLineCycle = 1;
    elseif contains(state,HI,'IgnoreCase',true)
        status = 'HIGH ACCURACY';
        powerLineCycle = 10;
    end
elseif isa(state,'double')
    if state < MAX_SPEED || state > MIN_SPEED
        powerLineCycle = state;
    else
        powerLineCycle = 1;
    end
    status = 'OTHER';
end

if powerLineCycle > 1 && powerLineCycle <= 10
    samplingPeriod = 5;                                                                                                                                                                                                             
elseif powerLineCycle > 0.1 && powerLineCycle <= 1
    samplingPeriod = 1;
elseif powerLineCycle > 0.01 && powerLineCycle <= 0.1
    powerLineCycle = 2 / 3;
elseif powerLineCycle >= 0.01
    samplingPeriod = 1 / 2;
end
% period = powerLineCycle / POWER_LINE;
% samplingPeriod = round(period,1,'significant');
samplingRate = 1 / samplingPeriod;

for channelNum = channelSelect
    remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
    gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
    if remainder == 1
        channel = 1;
    else
        channel = 2;
    end
    speed_str = sprintf('SENSe%d:CURRent:NPLCycles %f',channel,powerLineCycle);
    fprintf(gpib(gpibNum),speed_str);
end
fprintf('%s.\n',status);

end