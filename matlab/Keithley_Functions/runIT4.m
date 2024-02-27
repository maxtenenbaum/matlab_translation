%% Run Experiment
function [File,itPlot] = runIT4(File)
%% Constants
% Values
MATLAB_COLOR = {...
    '#0072BD',...   % blue
    '#D95319',...   % orange
    '#EDB120',...   % yellow
    '#7E2F8E',...   % purple
    '#77AC30',...   % green
    '#4DBEEE',...   % cyan
    '#A2142F'};     % maroon
MARKER_TYPE = {...
    'o',... % circle
    '+',... % plus
    '*',... % asterisk
    'x',... % cross
    '_',... % horizontal line
    '|',... % vertical line
    's',... % square
    'd',... % diamond
    '^',... % up-point triangle
    'v',... % down-point triangle
    '>',... % right-point triangle
    '<',... % left-point triangle
    'p',... % pentagon
    'h'};   % hexagon
MAX_CURRENT = 20e-3; 	% compliance at 20 mA
OVERFLOW = 1e37;        % overflow reading
ANNOT_DIM = [0.84 .65 .1 .1];
FONT_SIZE = 20;
FIG_WIDTH = 960;
FIG_HEIGHT = 720;
ARR_LENGTH = 1e5;

%% Variables
expID = File.Experiment.ID;
gpib_arr = File.Instrument.Object;
samplingRate = File.Instrument.Settings.Speed.SamplingRate;
samplingPeriod = File.Instrument.Settings.Speed.SamplingPeriod;
offset_arr = File.Instrument.Settings.RelativeOffset;
channelSelect = File.Experiment.Channels.Number;
channelNameList = File.Experiment.Channels.Name;
channelSelect_len = length(channelSelect);
savePath = File.Path;

% Initialize variablesS
time_fix_arr = zeros(ARR_LENGTH,1);
current_fix_matrix = zeros(ARR_LENGTH,channelSelect_len);
animatedLines = gobjects(channelSelect_len,1);
legend_arr = strings(channelSelect_len,1);
checkSteadyState = false;
checkConstant = false;
checkTimeStep = false;

% Temporary Save file
fileDate = datestr(now,'yymmdd_HHMMSS');
fileName = sprintf('%s_tempCT.mat',fileDate);
tempFile = fullfile(savePath,fileName);

% Instantiation
samplingRateControl = rateControl(samplingRate);   % sampling rate control

%% Determine Experiment
switch expID
    case 'IT'
        checkConstant = true;
        stepNum = 1;
        voltageBias = File.Experiment.Parameters.VoltageBias;
        timeStep = File.Experiment.Parameters.Duration;
        quitStep = false;
        ctFigNum = 1;

    case 'IV'
        checkSteadyState = true;
        stepNum = length(File.StepData);
        voltageBias = File.StepData(stepNum).VoltageBias;
        File.StepData(stepNum).Completed = false;
        File.StepData(stepNum).Completed = false;
        bufferLength = File.Experiment.Parameters.BufferLength;
        timeStep = inf;
        ctFigNum = channelSelect_len + 1;

    case {'CAP','STEP'}
        checkTimeStep = true;
        stepNum = length(File.StepData);
        timeStep = File.Experiment.Parameters.TimeStep;
        voltageBias = File.StepData(stepNum).VoltageBias;
        bufferLength = timeStep / samplingPeriod - 1;
        File.Experiment.Parameters.BufferLength = bufferLength;
        File.StepData(stepNum).Completed = false;
        ctFigNum = channelSelect_len + 1;
        File.StepData(stepNum).Completed = false;
end

current_fix_arr = zeros(1,channelSelect_len);
mean_arr = zeros(channelSelect_len,1);
if ~checkConstant
    File.Instrument.Processing(stepNum).Step = stepNum;
    File.Instrument.Processing(stepNum).Buffer = zeros(bufferLength,channelSelect_len);
    numOfSteps = File.Experiment.Parameters.NumberOfSteps;
    File.Instrument.Processing(stepNum).Values = zeros(1,channelSelect_len);
end

dateTimeStart = getDateTime();
for channel_idx = 1:channelSelect_len
    if checkConstant
        File.Data(channel_idx).Channel = channelNameList(channel_idx);
        File.Data(channel_idx).Voltage = voltageBias;
        File.Data(channel_idx).DateTimeStart = dateTimeStart;
    else
        File.StepData(stepNum).Data(channel_idx).Channel = channelNameList(channel_idx);
        File.StepData(stepNum).Data(channel_idx).Voltage = voltageBias;
        File.StepData(stepNum).Data(channel_idx).DateTimeStart = dateTimeStart;
    end
end

%% Plot Setup
% Plot
if checkConstant
    ctPlot_name = sprintf('Volage Bias: {\\itV}_{bias} =  %+.2f V',voltageBias);
    itPlot = figure(1);
else
    if voltageBias == 0
        stepName = sprintf('Step %d: {\\itV}_{bias} = %.2f V',stepNum,voltageBias);
    else
        stepName = sprintf('Step %d: {\\itV}_{bias} = %+.2f V',stepNum,voltageBias);
    end
    ctPlot_name = stepName;
    itPlot = figure(ctFigNum);
end
itPlot.WindowState = 'maximized';
clf;
ax = gca;
set(ax,'FontSize',FONT_SIZE);
xlabel('Time (s)');
ylabel('Current (A)');
ctPlot_title = 'Current vs. Time';
title(ctPlot_title);
subtitle(ctPlot_name);
set(itPlot,'CloseRequestFcn','set(fig_obj,"Visible","off");');
box on;
annot = gobjects(1);

% Legend
set(0,'CurrentFigure',itPlot);
for channel_idx = 1:channelSelect_len
    color = MATLAB_COLOR{channel_idx};
    marker = MARKER_TYPE{channel_idx};
    animatedLines(channel_idx) = animatedline;
    animatedLines(channel_idx).Color = color;
    animatedLines(channel_idx).LineStyle = 'none';
    animatedLines(channel_idx).Marker = marker;
    animatedLines(channel_idx).MarkerSize = 5;
    animatedLines(channel_idx).MarkerFaceColor = color;
    animatedLines(channel_idx).MarkerEdgeColor = color;
    if checkSteadyState
        animatedLines(channel_idx).MaximumNumPoints = bufferLength;
    end
end
leg = legend(channelNameList);
leg.AutoUpdate = 'off';
leg.Location = 'eastoutside';

% Instantiation
buttonHandleCT = uicontrol(...                  	% button handle
    'Style','PushButton',...
    'String','STOP',...
    'BackgroundColor','r',...
    'Callback','delete(gcbf)');

%% Function
if ~checkConstant
    quitStep = File.StepData(stepNum).Completed;
end
% Start voltage bias
setVoltageRange3(File,voltageBias); % set voltage range
setVoltageBias3(File,voltageBias);  % set voltage bias
clearBufferReading(File);
fprintf('\n');

% Collecting data
fprintf('Collecting data...\n');
sampleNum = 0;
startTime = tic;
timestamp0 = startTime;
while ~quitStep
    timestamp_off = toc(startTime);
    sampleNum = sampleNum + 1;
    File.Instrument.Processing(stepNum).NumberOfSamples = sampleNum;
    if sampleNum == 1
        timeOffset = timestamp_off;
    end
    % Keithley 6482 timestamp resets after 99,999.999 s
    % manually capturing timestamp
    timestamp = timestamp_off - timeOffset;
    time_fix = (sampleNum - 1) * samplingPeriod;
    %     time_fix_arr_alloc = [time_fix_arr;time_fix];
    %     time_fix_arr = time_fix_arr_alloc;
    time_fix_arr(sampleNum) = time_fix;

    % Take Measurement
    for channel_idx = 1:channelSelect_len
        channelNum = channelSelect(channel_idx);
        [gpibNum,channel] = channelToDeviceChannel(channelNum);
        if channel_idx == 1
            timestamp2 = toc(timestamp0);
        end
        selectChannel = sprintf('FORMat:ELEMents CURRent%d',channel);
        writeline(gpib_arr(gpibNum),selectChannel);
        writeline(gpib_arr(gpibNum),'READ?');
        current_str = readline(gpib_arr(gpibNum));
        current = str2double(current_str);
        offset = offset_arr(channel_idx);
        current_fix = current - offset;
        current_fix_arr(channel_idx) = current_fix;
        current_fix_matrix(sampleNum,channel_idx) = current_fix;
        sampleNum_arr = 1:sampleNum;
        channelTime_arr = time_fix_arr(sampleNum_arr);
        channelCurrent_arr = current_fix_matrix(sampleNum_arr,channel_idx);
        if checkConstant
            File.Data(channel_idx).Time = channelTime_arr;
            %             channelCurrent_arr = File.Data(channel_idx).Current;
            %             channelCurrent_arr_alloc = [channelCurrent_arr;current_fix];
            %             File.Data(channel_idx).Current = channelCurrent_arr_alloc;
            File.Data(channel_idx).Current = channelCurrent_arr;
        else
            File.StepData(stepNum).Data(channel_idx).Time = channelTime_arr;
            %             channelCurrent_arr = File.StepData(stepNum).Data(channel_idx).Current;
            %             channelCurrent_arr_alloc = [channelCurrent_arr;current_fix];
            %             File.StepData(stepNum).Data(channel_idx).Current = channelCurrent_arr_alloc;
            File.StepData(stepNum).Data(channel_idx).Current = channelCurrent_arr;
        end
    end
    %     current_fix_matrix_alloc = [current_fix_matrix;current_fix_arr];
    %     current_fix_matrix = current_fix_matrix_alloc;

    %     data_matrix = getBufferReading2(File);
    %     for channel_idx = 1:channelSelect_len
    %         current_arr = data_matrix{channel_idx};
    %         Data(channel_idx).Current = current_arr;
    %     end

    if sampleNum > 1
        samplingPeriod_calc = timestamp2 - timestamp1; %#ok<*NODEF>
        samplingRate_calc = 1 / samplingPeriod_calc;
    else
        samplingRate_calc = 1;
    end
    if ~checkSteadyState
        cycle100 = rem(sampleNum,100);
        if cycle100 == 0
            %             clc;
        end
    end

    clc;
    switch expID
        case 'IT'
            voltageBias = File.Data.Voltage;
            if voltageBias == 0
                fprintf('Voltage Bias: Vbias = %.2f V\n',voltageBias);
            else
                fprintf('Voltage Bias: Vbias = %+.2f V\n',voltageBias);
            end
        case {'IV','CAP','STEP'}
            if voltageBias == 0
                fprintf('Step %d: Vbias = %.2f V\n',stepNum,voltageBias);
            else
                fprintf('Step %d: Vbias = %+.2f V\n',stepNum,voltageBias);
            end
            %             bufferLength = File.Experiment.Parameters.BufferLength;
            %             numOfSD = File.Experiment.Parameters.StandardDeviations;
            %             fprintf('Buffer Length: n = %g\n',bufferLength);
            %             fprintf('Acceptable Standard Deviation: +/-%g SD\n',numOfSD);
            %         case {'CAP','STEP'}
            %             voltageBias = File.StepData(stepNum).VoltageBias;
            %             if voltageBias == 0
            %                 fprintf('Step %d: Vbias = %.2f V\n',stepNum,voltageBias);
            %             else
            %                 fprintf('Step %d: Vbias = %+.2f V\n',stepNum,voltageBias);
            %             end
    end
    fprintf('Samples: N = %d\n',sampleNum);
%     fprintf('Sample Time: t = %f s\n',timestamp2);
    fprintf('Fixed Time: t = %f s\n',time_fix);
%     latency = abs(time_fix-timestamp2);
%     fprintf('Latency: dt = %f s\n',latency);
    fprintf('Sampling Frequency: f = %f Hz\n',samplingRate_calc);

    File = getProcessing(File);
    quitStep = File.StepData(stepNum).Completed;
    if quitStep
        if checkSteadyState
            fprintf('Steady state found for all channels.\n\n');
        elseif checkTimeStep
            fprintf('Time step completed for all channels.\n\n');
        end
    end

    %% Plot
    % Annotation
    delete(annot);
    %     sampleTime_s = seconds(time_fixed);
    sampleTime_s = seconds(timestamp);
    sampleTime_dur = duration(sampleTime_s);
    sampleTime_str = string(sampleTime_dur,'hh:mm:ss.SSS');
    sampleNum_annot = sprintf('{\\itN} = %d',sampleNum);
    sampleFreq_annot = sprintf('{\\itf}_{s} = %.4f Hz',samplingRate_calc);
    sampleTime_annot = sprintf('{\\itt} = %s',sampleTime_str);
    sampleNum_text = sprintf('%s\n%s\n%s',...
        sampleNum_annot,...
        sampleFreq_annot,...
        sampleTime_annot);
    annot = annotation(...
        itPlot,...
        'textbox',ANNOT_DIM,...,
        'BackgroundColor','w',...
        'String',sampleNum_text,...
        'FontSize',FONT_SIZE-2,...
        'FitBoxToText','on');

    % Plot points
    try
        delete(trendLine);
    catch
    end
    trendLine = gobjects(1,channelSelect_len);
    try
        delete(exclude);
    catch
    end
    exclude = gobjects(1,channelSelect_len);
    for channel_idx = 1:channelSelect_len
        channelLine = animatedLines(channel_idx);
        if isvalid(channelLine)
            current_new = current_fix_arr(channel_idx);
            set(0,'CurrentFigure',itPlot);
            addpoints(channelLine,time_fix,current_new);
            color = MATLAB_COLOR{channel_idx};
            marker = MARKER_TYPE{channel_idx};
            hold on;
            set(0,'CurrentFigure',itPlot);
            if ~checkConstant
                if checkSteadyState && sampleNum >= bufferLength
                    start = sampleNum - bufferLength + 1;
                    sample_arr = start:sampleNum;
                    time_arr = sample_arr * samplingPeriod;
                    slope = File.StepData(stepNum).Data(channel_idx).Statistics.Slope;
                    intercept = File.StepData(stepNum).Data(channel_idx).Statistics.Intercept;
                    current_calc = polyval([slope intercept],time_arr);
                    trendLine(channel_idx) = plot(time_arr,current_calc,...
                        'LineStyle','--',...
                        'Color',color,...
                        'LineWidth',1); %#ok<*NASGU>
                elseif checkTimeStep
                    channelCurrentAvg = File.StepData(stepNum).Data(channel_idx).Statistics.Mean;
%                     sample_arr = 1:sampleNum;
%                     time_arr = sample_arr * samplingPeriod;
%                     trend = ones(sampleNum,1) * channelCurrentAvg;
                    trendLine(channel_idx) = yline(channelCurrentAvg,...
                        'LineStyle','--',...
                        'Color',color,...
                        'LineWidth',1); %#ok<*AGROW>
                end
            end
            exclude_idx = File.StepData(stepNum).Data(channel_idx).Statistics.Exclude.Index;
            if ~isempty(exclude_idx)
                exclude_time = File.StepData(stepNum).Data(channel_idx).Statistics.Exclude.Time;
                exclude_current = File.StepData(stepNum).Data(channel_idx).Statistics.Exclude.Current;
                if (checkSteadyState && sampleNum > bufferLength) || checkTimeStep
                    exclude(channel_idx) = scatter(exclude_time,exclude_current,72,...
                        'Marker',marker,...
                        'LineWidth',0.75,...
                        'MarkerEdgeColor','k',...
                        'MarkerFaceColor','none');
                end
            end
        end
    end

    hold off;
    drawnow;

    isAtCompliance = all(current_fix_arr > MAX_CURRENT);
    isAtOverflow = all(current_fix_arr > OVERFLOW);
    if isAtCompliance || isAtOverflow
        fprintf('All channels reached compliance (20 mA).\n');
        fprintf('Experiment terminating...');
        File.Experiment.Quit = true;
        break;
    end

    if ~ishandle(buttonHandleCT)
        fprintf('Experiment canceled by user...');
        File.Experiment.Quit = true;
        break;
    end

    if sampleNum >= bufferLength
        File.StepData(stepNum).Completed = true;
    end

    cycle10 = rem(sampleNum,10);
    if cycle10 == 0
        try
            if checkConstant
                Data = File.Data;
            else
                Data = File.StepData(stepNum);
            end
            save(tempFile,'Data');
        catch
        end
    end

    if ~checkConstant
        quitStep = File.StepData(stepNum).Completed;
        if quitStep
            break;
        else
            timestamp1 = timestamp2;
            waitfor(samplingRateControl);
        end
    end
end

% End
endTime = toc(startTime);
[~,endTime_use] = getEndTime(endTime);
delete(buttonHandleCT);
quitExp = File.Experiment.Quit;
if ~quitExp
    fprintf('Current vs. Time completed: %s\n\n',endTime_use);
else
    fprintf('OK.\n');
    fprintf('Current vs. Time canceled: %s\n\n',endTime_use);
end

dateTimeEnd = getDateTime();
for channel_idx = 1:channelSelect_len
    if checkConstant
        File.Data(channel_idx).DateTimeEnd = dateTimeEnd;
    else
        File.StepData(stepNum).Data(channel_idx).DateTimeEnd = dateTimeEnd;
    end
end

delete(tempFile);

end