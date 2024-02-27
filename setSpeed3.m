function File = setSpeed3(File,state)
%% Variables
gpib_arr = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;
samplingPeriod = 1;

%% Function
fprintf('Setting speed...');
for channelNum = channelSelect
    [gpibNum,channel] = channelToDeviceChannel(channelNum);
    writeline(gpib_arr(gpibNum),'DISPlay:ENABle?');
    isDisplayOn = str2num(readline(gpib_arr(gpibNum)));

    if isa(state,'char') || isa(state,'string')
        if contains(state,'FAST','IgnoreCase',true)
            status = 'FAST';
            powerLineCycle = 0.01;
            if isDisplayOn
                samplingPeriod = 0.25;
            else
                samplingPeriod = 0.2;
            end
        elseif contains(state,'MED','IgnoreCase',true)
            status = 'MEDIUM';
            powerLineCycle = 0.1;
            if isDisplayOn
                samplingPeriod = 0.5;
            else
                samplingPeriod = 0.4;
            end
        elseif contains(state,'NORM','IgnoreCase',true) || contains(state,DEF,'IgnoreCase',true)
            status = 'NORMAL';
            powerLineCycle = 1;
            samplingPeriod = 1;
        elseif contains(state,'HI','IgnoreCase',true)
            status = 'HIGH ACCURACY';
            powerLineCycle = 10;
            samplingPeriod = 5;
        end
    elseif isa(state,'double')
        if state > 1 && state <= 10
            samplingPeriod = 5;                                                                                                                                                                                                             
        elseif state > 0.1 && state <= 1
            samplingPeriod = 1;
        elseif state > 0.01 && state <= 0.1
            if samplingPeriod
                samplingPeriod = 5;
            else
                samplingPeriod = 0.4;
            end
        elseif state >= 0.01
            if isDisplayOn
                samplingPeriod = 0.25;
            else
                samplingPeriod = 0.2;
            end
        end
        status = 'OTHER';
    end

    samplingRate = 1 / samplingPeriod;
    speed_str = sprintf('SENSe%d:CURRent:NPLCycles %f',channel,powerLineCycle);
    writeline(gpib_arr(gpibNum),speed_str);
end

File.Instrument.Settings.Speed.Mode = state;
File.Instrument.Settings.Speed.NPLC = powerLineCycle;
File.Instrument.Settings.Speed.SamplingRate = samplingRate;
File.Instrument.Settings.Speed.SamplingPeriod = samplingPeriod;
% expID = File.Experiment.ID;
% if strcmpi(expID,'CAP') || strcmpi(expID,'STEP')
% %     voltageStep = File.Experiment.Parameters.VoltageStep;
%     timeStep = File.Experiment.Parameters.TimeStep;
%     bufferLength = timeStep / samplingPeriod - 1;
%     File.Experiment.Parameters.BufferLength = bufferLength;
% end
fprintf('%s.\n',status);

end