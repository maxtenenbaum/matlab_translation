function [cap,cap_str]= getCapacitance(voltage,current,voltageStep,timeStep)
%% Constants
MILLI_MAG = -3;
MICRO_MAG = -6;
NANO_MAG = -9;
N_TO_MILLI = 1e3;
N_TO_MICRO = 1e6;
N_TO_NANO = 1e9;

%% Variables
voltageMin = min(voltage);
voltageMax = max(voltage);
voltageWindow = abs(voltageMax - voltageMin);
scanRate = voltageStep / timeStep;

%% Function

areaUnderCurve = trapz(voltage,current);
cap = areaUnderCurve / (scanRate*voltageWindow);
capOrderOfMAg = floor(log10(cap));

if capOrderOfMAg <= NANO_MAG
    cap_scaled = cap * N_TO_NANO;
    cap_str = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bfG\\Omega}',...
        cap_scaled);
elseif capOrderOfMAg <= MICRO_MAG
    cap_scaled = cap * N_TO_MICRO;
    cap_str = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bfM\\Omega}',...
        cap_scaled);
elseif capOrderOfMAg <= MILLI_MAG
    cap_scaled = cap * N_TO_MILLI;
    cap_str = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bfk\\Omega}',...
        cap_scaled);
else
    cap_str = sprintf(...
        '{\\bf{\\itR}} = %.4g {\\bf\\Omega}',...
        cap);
end

end