%% Run Experiment
function [File,itPlot] = runIT2(File)
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

% Initialize variables
time_arr = [];
current_mat = double.empty(0,channelSelect_len);
annot = gobjects(1);
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
        stepNum = File.StepData(end).Step;
        voltageBias = File.StepData(stepNum).VoltageBias;
        File.StepData(stepNum).Completed = false;
        File.Instrument.Processing(stepNum).Filled = false;
        File.StepData(stepNum).Completed = false;
        bufferLength = File.Experiment.Parameters.BufferLength;
        timeStep = inf;
        ctFigNum = channelSelect_len + 1;

    case {'CAP','STEP'}
        checkTimeStep = true;
        stepNum = File.StepData(end).Step;
        timeStep = File.Experiment.Parameters.TimeStep;
        voltageBias = File.StepData(stepNum).VoltageBias;
        File.StepData(stepNum).Completed = false;
        ctFigNum = channelSelect_len + 1;
        File.StepData(stepNum).Completed = false;
end
if ~checkConstant
    File.Instrument.Processing(stepNum).Step = stepNum;
    File.Instrument.Processing(stepNum).Buffer = double.empty(0,channelSelect_len);
end

dateTimeStart = getDateTime();
for channel_idx = 1:channelSelect_len
    if checkConstant
        File.Data(channel_idx).Channel = channelNameList{channel_idx};
        File.Data(channel_idx).Voltage = voltageBias;
        File.Data(channel_idx).DateTimeStart = dateTimeStart;
    else
        File.StepData(stepNum).Data(channel_idx).Channel = channelNameList{channel_idx};
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
    stepName = sprintf('Step %d: {\\itV}_{bias} = %+.2f V',stepNum,voltageBias);
    ctPlot_name = stepName;
    itPlot = figure(ctFigNum);
end
set(itPlot,'CloseRequestFcn','set(fig_obj,"Visible","off");');
set(itPlot,'WindowState','maximized');
clf(itPlot);

% Instantiation
buttonHandle = uicontrol(...                  	% button handle
    'Style','PushButton',...
    'String','STOP',...
    'BackgroundColor','r',...
    'Callback','delete(gcbf)');

%% Start Voltage Bias
setVoltageRange2(File,voltageBias); % set voltage range
setVoltageBias2(File,voltageBias);  % set voltage bias
fprintf('\n');

%% Collecting data
fprintf('Collecting data...\n');
if ~checkConstant
    quitStep = File.StepData(stepNum).Completed;
end
clearBufferReading(File);
sampleNum = 0;
startTime = tic;
while ~quitStep
    timestamp_off = toc(startTime);
    sampleNum = sampleNum + 1;
    File.Instrument.Processing(stepNum).NumberOfSamples = sampleNum;
    if sampleNum == 1
        timeOffset = timestamp_off;
    end
    % manually capturing timestamp
    timestamp = timestamp_off - timeOffset;
    time_fix = (sampleNum - 1) * samplingPeriod;
    time_fix_arr_alloc = [time_arr;time_fix];
    time_arr = time_fix_arr_alloc;
    clear('time_fix_arr_alloc');

    % Take Measurement
    current_fix_arr = zeros(1,channelSelect_len);
    timestamp2 = toc(startTime);
    for channel_idx = 1:channelSelect_len
        channelNum = channelSelect(channel_idx);
        [gpibNum,channel] = channelToDeviceChannel(channelNum);
        selectChannel = sprintf('FORMat:ELEMents CURRent%d',channel);
        fprintf(gpib_arr(gpibNum),selectChannel);
        fprintf(gpib_arr(gpibNum),'READ?');
        current_str = fscanf(gpib_arr(gpibNum));
        current = str2double(current_str);
        offset = offset_arr(channel_idx);
        current_fix = current - offset;
        current_fix_arr(channel_idx) = current_fix;
    end
    current_fix_arr_alloc = [current_mat;current_fix_arr];
    current_mat = current_fix_arr_alloc;
    clear('current_fix_arr_alloc')

    % Store measurement
    for channel_idx = 1:channelSelect_len
        channelCurrent_arr = current_mat(:,channel_idx);
        if checkConstant
            File.Data(channel_idx).Time = time_arr;
            File.Data(channel_idx).Current = channelCurrent_arr;
        else
            File.StepData(stepNum).Data(channel_idx).Time = time_arr;
            File.StepData(stepNum).Data(channel_idx).Current = channelCurrent_arr;
        end
    end

    %% Print sampling information
    if sampleNum > 1
        samplingPeriod_calc = timestamp2 - timestamp1; %#ok<*NODEF>
        samplingRate_calc = 1 / samplingPeriod_calc;
    else
        samplingRate_calc = 1;
    end
    switch expID
        case 'IT'
            fprint('\n');
            voltageBias = File.Data.Voltage;
            if voltageBias == 0
                fprintf('Voltage Bias: Vbias = %.2f V\n',voltageBias);
            else
                fprintf('Voltage Bias: Vbias = %+.2f V\n',voltageBias);
            end
        case 'IV'
            clc;
            if voltageBias == 0
                fprintf('Step %d: Vbias = %.2f V\n',stepNum,voltageBias);
            else
                fprintf('Step %d: Vbias = %+.2f V\n',stepNum,voltageBias);
            end
            bufferLength = File.Experiment.Parameters.BufferLength;
            numOfSD = File.Experiment.Parameters.StandardDeviations;
            fprintf('Buffer Length: n = %g\n',bufferLength);
            fprintf('Acceptable Standard Deviation: +/-%g SD\n',numOfSD);
        case {'CAP','STEP'}
            clc;
            voltageBias = File.StepData(stepNum).VoltageBias;
            fprintf('Step %d: Vbias = %+.2f V\n',stepNum,voltageBias);
    end
    fprintf('Samples: N = %d\n',sampleNum);
    fprintf('Sample Time: t = %f s\n',timestamp2);
    fprintf('Fixed Time: t = %f s\n',time_fix);
    fprintf('Sampling Frequency: f = %f Hz\n',samplingRate_calc);

    %% Process measurement
    File = getProcessing2(File);
    quitStep = File.StepData(stepNum).Completed;
    if quitStep
        if checkSteadyState
            fprintf('Steady state found for all channels.\n\n');
        elseif checkTimeStep
            fprintf('Time step completed for all channels.\n\n');
        end
    end

    %% Plot measurement
    set(0,'CurrentFigure',itPlot);
    delete(annot);

    % Data
    for channel_idx = 1:channelSelect_len
        channelCurrent_arr = current_mat(:,channel_idx);
        color = MATLAB_COLOR{channel_idx};
        marker = MARKER_TYPE{channel_idx};
        plot(time_arr,channelCurrent_arr,...
            'Color',color,...
            'LineStyle','none',...
            'Marker',marker,...
            'MarkerSize',5,...
            'MarkerFaceColor',color,...
            'MarkerEdgeColor',color);
        hold on;
        %         if checkSteadyState
        %             start_idx = sampleNum - bufferLength + 1;
        %             end_idx = sampleNum;
        %             timeStart = time_arr(start_idx);
        %             timeEnd = time_arr(end_idx);
        %             xlim([timeStart timeEnd]);
        %         end

        if strcmpi(expID,'IV') || strcmpi(expID,'CAP')
            if sampleNum > bufferLength
                start_idx = sampleNum - bufferLength + 1;
                time_fit = time_arr(start_idx:sampleNum);
                slope = File.StepData(stepNum).Data(channel_idx).Statistics.Slope;
                intercept = File.StepData(stepNum).Data(channel_idx).Statistics.Intercept;
                current_fit = polyval([slope intercept],time_fit);
                plot(time_fit,current_fit,...
                    'LineStyle','--',...
                    'Color',color,...
                    'LineWidth',1,...
                    'HandleVisibility','off');
                exclude_idx = File.StepData(stepNum).Data(channel_idx).Statistics.Exclude.Index;
                if ~isempty(exclude_idx)
                    exclude_time = File.StepData(stepNum).Data(channel_idx).Statistics.Exclude.Time;
                    exclude_current = File.StepData(stepNum).Data(channel_idx).Statistics.Exclude.Current;
                    scatter(exclude_time,exclude_current,72,...
                        'Marker',marker,...
                        'LineWidth',0.75,...
                        'MarkerEdgeColor','k',...
                        'HandleVisibility','off');
                end
            end
        end
    end

    % Labels
    ax = gca;
    set(ax,'FontSize',FONT_SIZE);
    xlabel('Time (s)');
    ylabel('Current (A)');
    title('Current vs. Time');
    subtitle(ctPlot_name);
    box on;

    % Legend
    set(0,'CurrentFigure',itPlot);
    leg = legend(channelNameList);
    set(leg,'AutoUpdate','off');
    set(leg,'Location','eastoutside');

    % Annotations
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
    drawnow;
    hold off;

    %% Save temp file
    if checkConstant
        Data = File.Data;
    else
        Data = File.StepData(stepNum);
    end
    save(tempFile,'Data');

    %% Check for quit
    % Compliance
    isAtCompliance = all(current_fix_arr > MAX_CURRENT);
    isAtOverflow = all(current_fix_arr > OVERFLOW);
    if isAtCompliance || isAtOverflow
        fprintf('All channels reached compliance (20 mA).\n');
        fprintf('Experiment terminating...');
        File.Experiment.Quit = true;
    end

    % User stop
    if ~ishandle(buttonHandle)
        fprintf('Experiment canceled by user...');
        File.Experiment.Quit = true;
    end

    %% Check for end
    % End of duration
    if timestamp >= timeStep
        if ~checkConstant
            File.StepData(stepNum).Completed = true;
        end
        quitStep = true;
    else
        timestamp1 = timestamp2;
        waitfor(samplingRateControl);
    end
end

% End
endTime = toc(startTime);
[~,endTime_use] = getEndTime(endTime);
delete(buttonHandle);
% delete(annot);
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