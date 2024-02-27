 %% Run Experiment
function [structCT,runExp,currentAvg,ctPlot] = runCT(...
    savePath,...
    voltageBias,...
    channelSelect,...
    channelSelect_len,... 
    channelNameList,...
    gpib,...
    samplingRate,...
    offsetArray,...
    structCT,...
    experiment,...
    bufferLength,...
    numOfStdDev,...
    stepNum)
%% Constants
% Values
% VISA_ERROR_ID = 'instrument:fprintf:opfailed';
EXP_CONSTANT = 'CONSTANT';
EXP_STEADY = 'STEADY';
% TRIPLET = 3;
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
MAX_NUM_OF_CHANNEL = 2; % max number of channels per gpib devices
MAX_CURRENT = 20e-3; 	% compliance at 20 mA
OVERFLOW = 1e37;      % overflow reading
ZERO = 0;
ONE = 1;
TWO = 2;
THREE = 3;
FOUR = 4;
TEN = 10;
HUNDRED = 100;
FIRST = 1;
SECOND = 2;
YES = 1;
NO = 0;
ANNOT_DIM = [.15 .6 .2 .2];
TIME_FORMAT = 'hh:mm:ss.SSS';
DATE_TIME_FORMAT = 'yyyy-MM-dd HH:mm:ss.SSS';
DATE_TIME_FILE_FORMAT = 'yymmdd_HHMMSS';
FONT_SIZE = 18;
FIG_WIDTH = 960;
FIG_HEIGHT = 720;

%% Variables
screenSize = get(0,'ScreenSize');
screenWidth = screenSize(THREE);
screenHeight = screenSize(FOUR);
channelLine = gobjects(channelSelect_len,ONE);
legend_array = strings(channelSelect_len,ONE);
currentArray = zeros(channelSelect_len,ONE);
currentAvg = zeros(channelSelect_len,ONE);
steadyState = zeros(channelSelect_len,ONE);
bufferMatrix = double.empty(channelSelect_len,ZERO);
slopeArray = zeros(channelSelect_len,ONE);
interceptArray = zeros(channelSelect_len,ONE);
checkSteadyState = 0;
checkConstant = 0;
checkTimeStep = 0;
isBufferFull = 0;
sampleNum = 0;
runCTExp = 1;
runExp = 1;

% Temporary Save file
fileDate = datestr(now,DATE_TIME_FILE_FORMAT);
fileName = sprintf('%s_tempCT.mat',fileDate);
tempFile = fullfile(savePath,fileName);

%% Exclusion Structure
[structExclude] = initStruct('exclude');
fprintf('\n');

%% Determine Experiment
if isstring(experiment) || ischar(experiment)
    if contains(experiment,EXP_STEADY,'IgnoreCase',true)
        checkSteadyState = 1;
    elseif contains(experiment,EXP_CONSTANT,'IgnoreCase',true)
        checkConstant = 1;
    end
elseif isnumeric(experiment)
    checkTimeStep = 1;
    timeStep = experiment;
end

%% Plot Setup
% Plot
% figAll = findall(groot,'Type','figure');
% numOfFig = length(figAll);
if checkSteadyState == YES
    ctFigNum = channelSelect_len + ONE;
    if voltageBias == ZERO
        stepName = sprintf('Step %d: %.2f V',stepNum,voltageBias);
    else
        stepName = sprintf('Step %d: %+.2f V',stepNum,voltageBias);
    end
    ctPlot_name = stepName;
%     ctPlot = figure('Name',ctPlot_name,'NumberTitle','off','WindowStyle','docked');
%     set(get(handle(ctPlot),'javaframe'),'GroupName','windowCT');
%     ctPlot = figure(...
%         'Name',ctPlot_name,...
%         'WindowState','maximized');
    ctPlot = figure(ctFigNum);
elseif checkConstant == YES
    ctPlot_name = sprintf('Volage Bias: %.2f V',voltageBias);
    ctPlot = figure(FIRST);
elseif checkTimeStep == YES
    ctFigNum = TWO * channelSelect_len + ONE;
    if voltageBias == ZERO
        stepName = sprintf('Step %d: %.2f V',stepNum,voltageBias);
    else
        stepName = sprintf('Step %d: %+.2f V',stepNum,voltageBias);
    end
    ctPlot_name = stepName;
%     ctPlot = figure(...
%         'Name',ctPlot_name,...
%         'WindowState','maximized');
    ctPlot = figure(ctFigNum);
end
ctPlot.WindowState = 'maximized';
clf;
set(gca,'FontSize',FONT_SIZE);
% set(ctPlot,'position',[screenWidth,screenHeight,FIG_WIDTH,FIG_HEIGHT]);
xlabel('Time (s)');
ylabel('Current (A)');
ctPlot_title = 'Current vs. Time';
title(ctPlot_title);
subtitle(ctPlot_name);

% Legend
set(0,'CurrentFigure',ctPlot);
set(gcf,'CloseRequestFcn','set(fig_obj,"Visible","off");');
for channel_idx = FIRST:channelSelect_len
%     color = de2bi(channel_idx,TRIPLET);
    color = MATLAB_COLOR{channel_idx};
    marker = MARKER_TYPE{channel_idx};
    channelLine(channel_idx) = animatedline;
    channelLine(channel_idx).Color = color;
    legend_array(channel_idx) = channelNameList(channel_idx);
    channelLine(channel_idx).LineStyle = 'none';
    channelLine(channel_idx).Marker = marker;
    channelLine(channel_idx).MarkerSize = 5;
    channelLine(channel_idx).MarkerFaceColor = color;
    channelLine(channel_idx).MarkerEdgeColor = color;
    if checkSteadyState == YES
        channelLine(channel_idx).MaximumNumPoints = bufferLength;
    end
end
leg = legend(legend_array);
% if channelSelect_len <= THREE
%     leg.NumColumns = 1;
% elseif <= FOUR
% leg.NumColumns = 3;
% leg.NumColumns = 3;
leg.AutoUpdate = 'off';

% Instantiation
samplingRateControl = rateControl(samplingRate);   % sampling rate control
samplingPeriod = ONE / samplingRate;
buttonHandleCT = uicontrol(...                  	% button handle
    'Style','PushButton',...
    'String','STOP',...
    'BackgroundColor','r',...
    'Callback','delete(gcbf)');

%% Function
% Start voltage bias
setVoltageRange(voltageBias,channelSelect,gpib);% set voltage range
setVoltageBias(voltageBias,channelSelect,gpib); % set voltage bias
fprintf('\n');

% Collecting data
fprintf('Collecting data...\n');
startTime = tic;
timestamp0 = startTime;
while runCTExp
    timestamp_off = toc(startTime);
    sampleNum = sampleNum + ONE;
    if sampleNum == FIRST
        timeOffset = timestamp_off;
        dateTimeStart_now = now;
        dateTimeStart_conv = datetime(dateTimeStart_now,'ConvertFrom','datenum');
        dateTimeStart_fix = datetime(dateTimeStart_conv,'Format',DATE_TIME_FORMAT);
        dateTimeStart = string(dateTimeStart_fix);
    end
    % Keithley 6482 timestamp resets after 99,999.999 s
    % manually capturing timestamp
    timestamp = timestamp_off - timeOffset;
    time_fixed = (sampleNum - ONE) * samplingPeriod;
    if checkConstant == YES
        fprintf('Samples: N = %d\n',sampleNum);
        fprintf('Sampling time: %d s\n',time_fixed);
        fprintf('Timestamp: %g s\n',timestamp);
    end
    
    % Take Measurement
%     errFound = 1;
%     while errFound == YES
%         try
            for channel_idx = FIRST:channelSelect_len
                channelNum = channelSelect(channel_idx);
                remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
                gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
                if remainder == ONE
                    channel = 1;
%                     calcChannel = channel + MAX_NUM_OF_CHANNEL;
                else
                    channel = 2;
%                     calcChannel = channel + MAX_NUM_OF_CHANNEL;
                end
                
%                 isRelStateOn = relStateArray(channel_idx);
                if channel_idx == FIRST
                    timestamp2 = toc(timestamp0);
                end
%                 if isRelStateOn == YES
%                     fprintf(gpib(gpibNum),'INIT');
%                     selectChannel = sprintf('CALC%d:DATA?',calcChannel);
%                     fprintf(gpib(gpibNum),selectChannel);
%                     current_str = fscanf(gpib(gpibNum));
%                     current = str2double(current_str);
%                     currentArray(channel_idx) = current;
%                 else
                    selectChannel = sprintf('FORMat:ELEMents CURRent%d',channel);
                    fprintf(gpib(gpibNum),selectChannel);
                    fprintf(gpib(gpibNum),'READ?');
                    current_str = fscanf(gpib(gpibNum));
                    current = str2double(current_str);
                    offset = offsetArray(channel_idx);
                    current_fix = current - offset;
                    currentArray(channel_idx) = current_fix;
%                 end
                
            if sampleNum == SECOND
                time_fixed_array = structCT(channel_idx).Time(FIRST:sampleNum-ONE);
                time_fixed_array_alloc = [time_fixed_array;time_fixed];
                structCT(channel_idx).Time = time_fixed_array_alloc;
                
                current_array = structCT(channel_idx).Current(FIRST:sampleNum-ONE);
                current_array_alloc = [current_array;current_fix];
                structCT(channel_idx).Current = current_array_alloc;
            else
                structCT(channel_idx).Time(sampleNum) = time_fixed;
                structCT(channel_idx).Current(sampleNum) = current_fix;
            end
                structCT(channel_idx).DateTimeStart = dateTimeStart;
                
%                 errFound = 0;
            end
            if sampleNum > FIRST
                samplingPeriod_calc = timestamp2 - timestamp1; %#ok<*NODEF>
                samplingRate_calc = ONE / samplingPeriod_calc;
            else
                samplingRate_calc = 1;
            end 
            if checkSteadyState == NO
                fprintf('\n');
                cycle100 = rem(sampleNum,HUNDRED);
                if cycle100 == ZERO
                    clc;
                end
            end
%         catch err
%             isVisaErr = strcmp(err.identifier,VISA_ERROR_ID);
%             if isVisaErr == YES
%                 fprintf('Error: %s\n',isVisaErr)
%                 try
%                     closeKeithley(channelSelect,gpib);
%                 catch
%                 end
%                 [gpib] = initKeithley();
%             end
%         end
    
    % Check for steady state
    if checkSteadyState == YES
        clc;
        fprintf('Step %d: %g V\n',stepNum,voltageBias);
        [...
            runCTExp,...
            isBufferFull,...
            bufferMatrix,...
            structExclude,...
            slopeArray,...
            interceptArray,...
            steadyState,...
            isSteadyStateFound]...
            = findSteadyState(...
                runCTExp,...
                bufferLength,...
                numOfStdDev,...
                channelSelect_len,...
                channelNameList,...
                samplingPeriod,...
                sampleNum,...
                currentArray,...
                bufferMatrix,...
                slopeArray,...
                interceptArray,...
                structExclude,...
                isBufferFull,...
                steadyState);

        currentAvg = steadyState;

        if isSteadyStateFound == YES
            fprintf('Steady state found for all channels.\n\n');
            runCTExp = 0;
        end
    end

    if checkTimeStep == YES
        clc;
        fprintf('Step %d: %g V\n',stepNum,voltageBias);
        [...
            runCTExp,...
            isBufferFull,...
            bufferMatrix,...
            structExclude,...
            slopeArray,...
            interceptArray,...
            currentAvg]...
            = findCurrentAvg(...
                runCTExp,...
                bufferLength,...
                numOfStdDev,...
                channelSelect_len,...
                channelNameList,...
                samplingPeriod,...
                sampleNum,...
                currentArray,...
                bufferMatrix,...
                slopeArray,...
                interceptArray,...
                structExclude,...
                isBufferFull);
        
        if sampleNum == bufferLength
            runCTExp = 0;
        end 
    end

    % Plot
%     sampleTime_s = seconds(time_fixed);
    sampleTime_s = seconds(timestamp);
    sampleTime_dur = duration(sampleTime_s);
    sampleTime_str = string(sampleTime_dur,TIME_FORMAT);
    sampleNum_annot = sprintf('{\\itN} = %d',sampleNum);
    sampleFreq_annot = sprintf('{\\itf}_{s} = %.4f Hz',samplingRate_calc);
    sampleTime_annot = sprintf('{\\itt} = %s',sampleTime_str);
    sampleNum_text = sprintf('%s\n%s\n%s',...
        sampleNum_annot,...
        sampleFreq_annot,...
        sampleTime_annot);
    if exist('annot','var') == YES
        if isvalid(annot)
            delete(annot);
        end
    end
    try
        annot = annotation(...
            ctPlot,...
            'textbox',ANNOT_DIM,...
            'String',sampleNum_text,...
            'FontSize',FONT_SIZE,...
            'FitBoxToText','on');
    catch
    end
    if checkSteadyState == YES
        if sampleNum > bufferLength
            delete(trendLine);
            delete(exclude);
        end
        trendLine = gobjects(channelSelect_len,ONE);
        exclude = gobjects(channelSelect_len,ONE);
        for channel_idx = FIRST:channelSelect_len
            line = channelLine(channel_idx);
            if isvalid(line)
                current_new = currentArray(channel_idx);
                set(0,'CurrentFigure',ctPlot);
                box on;
                addpoints(line,time_fixed,current_new);
                leg.Location = 'best';
                drawnow;
            end
            if checkSteadyState == YES
                if sampleNum >= bufferLength
                    start = sampleNum - bufferLength + ONE;
    %                 shift = bufferLength / TEN;
    %                 start_shifted = start - shift;
    %                 end_shifted = sampleNum + shift;
    %                 if start > shift
    %                     sampleArray = start_shifted:end_shifted;

    %                 else
    %                     sampleArray = FIRST:end_shifted;
    %                 end
                    sampleArray = start:sampleNum;
                    timeArray = sampleArray * samplingPeriod;
                    slope = slopeArray(channel_idx);
                    intercept = interceptArray(channel_idx);
                    current_calc = polyval([slope intercept],timeArray);
                    hold on;
                    try
                        set(0,'CurrentFigure',ctPlot);
                    catch
                    end
%                     color = de2bi(channel_idx,TRIPLET);
                    color = MATLAB_COLOR{channel_idx};
                    trendLine(channel_idx) = plot(timeArray,current_calc,...
                        'LineStyle','--',...
                        'Color',color,...
                        'LineWidth',1);
                    box on;
                    exclude_idx = structExclude(channel_idx).Index;
                    if ~isempty(exclude_idx)
                        exclude_time = structExclude(channel_idx).Time;
                        exclude_current = structExclude(channel_idx).Current;
                        marker = MARKER_TYPE{channel_idx};
                        exclude(channel_idx) = scatter(exclude_time,exclude_current,72,...
                            'Marker',marker,...
                            'LineWidth',0.75,...
                            'MarkerEdgeColor','k');
                    end
                end
            end
        end
    end
    
    if checkConstant == YES
        for channel_idx = FIRST:channelSelect_len
            line = channelLine(channel_idx);
            if isvalid(line)
                current_new = currentArray(channel_idx);
                set(0,'CurrentFigure',ctPlot);
                addpoints(line,time_fixed,current_new);
                box on;
                drawnow;
            end
        end
    end
    
    if checkTimeStep == YES
        if sampleNum > TWO
            delete(averageLine);
            delete(exclude);
        end
        averageLine = gobjects(channelSelect_len,ONE);
        exclude = gobjects(channelSelect_len,ONE);
        for channel_idx = FIRST:channelSelect_len
            line = channelLine(channel_idx);
            if isvalid(line)
                current_new = currentArray(channel_idx);
                set(0,'CurrentFigure',ctPlot);
                addpoints(line,time_fixed,current_new);
                drawnow;
            end
            if sampleNum > ONE
                hold on;
                try
                    set(0,'CurrentFigure',ctPlot);
                catch
                end
%                 color = de2bi(channel_idx,TRIPLET);
                color = MATLAB_COLOR{channel_idx};
                currentAvgVal = currentAvg(channel_idx);
                averageLine(channel_idx) = yline(currentAvgVal,...
                    'LineStyle','--',...
                    'Color',color,...
                    'LineWidth',1);
                exclude_idx = structExclude(channel_idx).Index;
                if ~isempty(exclude_idx)
                    exclude_time = structExclude(channel_idx).Time;
                    exclude_current = structExclude(channel_idx).Current;
                    marker = MARKER_TYPE{channel_idx};
                    exclude(channel_idx) = scatter(exclude_time,exclude_current,72,...
                        'Marker',marker,...
                        'LineWidth',0.75,...
                        'MarkerEdgeColor','k');
                end
            end
        end
    end
    
    atCompliance = all(currentArray > MAX_CURRENT);
    atOverflow = all(currentArray > OVERFLOW);
    if atCompliance == YES || atOverflow == YES
        fprintf('All channels reached compliance (20 mA).\n');
        fprintf('Experiment terminating...');
        runExp = 0;
        runCTExp = 0;
    end

    if ~ishandle(buttonHandleCT)
        fprintf('Experiment canceled by user...');
        runExp = 0;
        runCTExp = 0;
    end

    cycle10 = rem(sampleNum,TEN);
    if cycle10 == ZERO
        try
            save(tempFile,'structCT');
        catch
        end
    end
    
    if runCTExp == YES
        timestamp1 = timestamp2;
        waitfor(samplingRateControl);
    end
end

% End
endTime = toc(startTime);
delete(buttonHandleCT);
delete(annot);
if runExp == YES
    fprintf('Current vs. Time completed: %f s\n\n',endTime);
else
    fprintf('OK.\n\n');
    fprintf('Current vs. Time canceled: %f s\n\n',endTime);
end
dateTimeEnd_now = now;
dateTimeEnd_conv = datetime(dateTimeEnd_now,'ConvertFrom','datenum');
dateTimeEnd_fix = datetime(dateTimeEnd_conv,'Format',DATE_TIME_FORMAT);
dateTimeEnd = string(dateTimeEnd_fix);
for channel_idx = FIRST:channelSelect_len
    structCT(channel_idx).Voltage = voltageBias;
    structCT(channel_idx).DateTimeStart = dateTimeStart;
    structCT(channel_idx).DateTimeEnd = dateTimeEnd;
end
delete(tempFile);

end