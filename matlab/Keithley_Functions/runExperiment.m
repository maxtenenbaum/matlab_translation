function [File,quitExp] = runExperiment(File)
try
    %% Constants
    % Values
    MATLAB_COLOR = { ...
        '#0072BD', ...   % blue
        '#D95319', ...   % orange
        '#EDB120', ...   % yellow
        '#7E2F8E', ...   % purple
        '#77AC30', ...   % green
        '#4DBEEE', ...   % cyan
        '#A2142F', ...  % maroon
        "#FF0000", ...
        "#00FF00", ...
        "#0000FF", ...
        "#00FFFF", ...
        "#FF00FF", ...
        "#FFFF00"};
    LINE_STYLE = {'-','--',':','-.'};
    MARKER_TYPE = { ...
        'o', ... % circle
        '+', ... % plus
        '*', ... % asterisk
        'x', ... % cross
        's', ... % square
        'd', ... % diamond
        '^', ... % up-point triangle
        'v', ... % down-point triangle
        '>', ... % right-point triangle
        '<', ... % left-point triangle
        'p', ... % pentagon
        'h'};   % hexagon
    ANNOT_DIM = [.15 .65 .2 .2];
    FONT_SIZE = 20;
    FIG_WIDTH = 960;
    FIG_HEIGHT = 720;

    %% Variables
    expID = File.Experiment.ID;
    subjectName = File.Subject;
    emailAddress = File.Email;
    File.Experiment.Quit = false;

    % Channels
    channelSelect = File.Experiment.Channels.Number;
    channelNameList = File.Experiment.Channels.Name;
    channelSelect_len = length(channelSelect);

    % Voltage Parameters
    switch expID
        case'IT'
            numOfCycles = 0;
        case 'IV'
            [cycleList,cycleStart_array] = getCycleList(File);
            numOfCycles = File.Experiment.Parameters.Cycles;
        case 'CAP'
            [cycleList,cycleStart_array] = getCycleList(File);
            numOfCycles = File.Experiment.Parameters.Cycles;
        case 'STEP'
            [sweepList,sweepStart_arr] = getSweepList(File);
            cycleList = sweepList;
            cycleStart_array = sweepStart_arr;
            numOfSweeps = File.Experiment.Parameters.Sweeps;
            numOfCycles = numOfSweeps;
    end

    % Measurement
    if contains2(expID,'it')
        voltageList = File.Experiment.Parameters.VoltageBias;
    else
        voltageList = File.Experiment.Parameters.VoltageList;
        lowerLimit = min(voltageList);
        upperLimit = max(voltageList);
        if lowerLimit == 0 && upperLimit == 0
            ivPlot_title = sprintf('Current vs. Voltage: %.2f to %.2f V',lowerLimit,upperLimit);
        elseif lowerLimit == 0
            ivPlot_title = sprintf('Current vs. Voltage: %.2f to %+.2f V',lowerLimit,upperLimit);
        elseif upperLimit == 0
            ivPlot_title = sprintf('Current vs. Voltage: %+.2f to %.2f V',lowerLimit,upperLimit);
        else
            ivPlot_title = sprintf('Current vs. Voltage: %+.2f to %+.2f V',lowerLimit,upperLimit);
        end
        numOfSteps = File.Experiment.Parameters.NumberOfSteps;
        current_matrix = zeros(numOfSteps,channelSelect_len);
        voltageStep = File.Experiment.Parameters.VoltageStep;
        % bounds
        xMin = lowerLimit - 2*voltageStep;
        xMax = upperLimit + 2*voltageStep;
        xLimits = [xMin xMax];
        xBounds_min =lowerLimit - voltageStep;
        xBounds_max = upperLimit + voltageStep;
        xRange = xBounds_min:xBounds_max;
        res_arr = zeros(1,numOfCycles);
        r2_arr = zeros(1,numOfCycles);
        for channel_idx = 1:channelSelect_len
            File.Data(channel_idx).Resistance = res_arr;
            File.Data(channel_idx).Regression = r2_arr;
        end
    end
    if contains2(expID,{'CAP','STEP'})
        timeStep = File.Experiment.Parameters.TimeStep;
        samplingPeriod = File.Instrument.Settings.Speed.SamplingPeriod;
        bufferLength = timeStep / samplingPeriod - 1;
        File.Experiment.Parameters.BufferLength = bufferLength;
    end

    % Screen
    screenSize = get(0,'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

    % Annotation
    annot_text = cell(numOfCycles,channelSelect_len);

    %% Function
    % Creat plot windows
    if ~contains2(expID,'it')
        ivFig_arr = createWindow('windowIV',channelSelect_len,channelNameList);
        cycleLegend_cell = {};
    end
    drawnow;

    setSource2(File,'on');                     % turn on source
    startTime = tic;
    dateTimeStart = getDateTime();
    for stepNum = 1:numOfSteps
        voltageBias = voltageList(stepNum);
        setVoltageRange2(File,voltageBias); % set voltage range
        if numOfCycles == 1
            cycleNum = 1;
        else
            if ismember(stepNum,cycleStart_array)
                cycleNum = find(cycleStart_array == stepNum);
            end
        end

        if ~contains2(expID,'it')
            File.StepData(stepNum).Step = stepNum;
            File.StepData(stepNum).VoltageBias = voltageBias;
            File.StepData(stepNum).Data = initStruct2('it');
            for channel_idx = 1:channelSelect_len
                channelName = channelNameList(channel_idx);
                File.Data(channel_idx).Channel = channelName;
                File.StepData(stepNum).Data(channel_idx).Channel = channelName;
                File.StepData(stepNum).Data(channel_idx).Voltage = voltageBias;
            end
        else
            for channel_idx = 1:channelSelect_len
                channelName = channelNameList(channel_idx);
                File.Data(channel_idx).Channel = channelName;
                File.Data(channel_idx).Voltage = voltageBias;
            end
        end
        fprintf('\n');

        %% Run Experiment
        beep;
        [File,itPlot] = runIT3(File);
        quitExp = File.Experiment.Quit;
        if quitExp                             % stop experiment
            fprintf('OK\n\n');
        end

        %% Save I-T Data
        % Spreadsheet
        [it_mat,it_xlsx] = saveIT2(File,itPlot);
        emailFiles = {it_mat,it_xlsx};
        fprintf('\n');
        if quitExp
            break;
        end

        %% Store I-V Data
        if ~contains2(expID,'IT')
            % Steady-state current
            %         if contains2(expID,'IV')
            processed_arr = File.Instrument.Processing(stepNum).Values;
            current_matrix(stepNum,:) = processed_arr;
            %         end

            %% Check Cycle
            stepNum_arr = 1:stepNum;
            switch expID
                case {'IV','CAP'}
                    presentCycle_idx = cycleList{cycleNum};
                    presentCycleStart_idx = presentCycle_idx(1);
                    presentStep_idx = presentCycleStart_idx:stepNum;
                    isCycleDone = isequal(presentCycle_idx,stepNum_arr);
                case 'STEP'

            end

            %% I-V Plot
            annot = gobjects(numOfCycles,channelSelect_len); %#ok<*NASGU>
            trendline = gobjects(channelSelect_len,1);
            %         delete(findall(ivFig_arr,'type','annotation'))
            
            for channel_idx = 1:channelSelect_len
                % Figure
                annot_text_cell = cell(numOfCycles,1);
                channelName = channelNameList(channel_idx);
                ivPlot_idx = ivFig_arr(channel_idx);
                ivPlot = figure(ivPlot_idx);
                clf;
                ax = gca;
                % Plot values
%                 if contains2(expID,'IV')
%                     channelCurrentSteps_arr = current_matrix(stepNum_arr,channel_idx);
%                 else
%                     channelCurrentStep = File.StepData(stepNum).Data(channel_idx).Statistics.Mean;
%                     current_matrix(stepNum,channel_idx) = channelCurrentStep;
%                 end
                channelCurrentSteps_arr = current_matrix(stepNum_arr,channel_idx);
                voltageSteps_arr = voltageList(stepNum_arr);
                color = MATLAB_COLOR{channel_idx};
                lineStyle = LINE_STYLE{cycleNum};
                marker = MARKER_TYPE{channel_idx};
                plot(voltageSteps_arr,channelCurrentSteps_arr, ...
                    'Color',color, ...
                    'LineStyle',lineStyle, ...
                    'Marker',marker, ...
                    'MarkerSize',8, ...
                    'MarkerFaceColor',color, ...
                    'MarkerEdgeColor',color); %#ok<*SAGROW>
                hold on;

                % Labels
                %             set(fig, ...
                %                 'position',[screenWidth,screenHeight,FIG_WIDTH,FIG_HEIGHT]);
                % titles
                title(ivPlot_title);
                ivPlot_subtitle = sprintf('Channel: %s',channelName);
                subtitle(ivPlot_subtitle);
                % axes
                xlabel('Voltage (V)');
                ylabel('Current (A)');
                xlim(xLimits);
                ylim('tight');
                ylim('tickaligned');
                ytickformat('%.2g');
                ax.FontSize = FONT_SIZE;

                if stepNum > 1
                    if ~contains2(expID,'STEP')
                        % Capacitance
                        if contains2(expID,'CAP') && isCycleDone
                            [cap,cap_str] = getCapacitance(voltageSteps_arr,channelCurrentSteps_arr,voltageStep,timeStep);
                            File.Data(channel_idx).Capacitance = cap(cycleNum);
                        end
                        % Resistance
                        % trendline
                        presentX = voltageList(presentStep_idx);
                        presentY = channelCurrentSteps_arr(presentStep_idx);
                        [slope,intercept,r2] = getLinReg(presentX,presentY);
                        trend = polyval([slope intercept],xRange);
                        % resistance
                        [res,res_char]= getResistance(slope);
                        res_arr = File.Data(channel_idx).Resistance;
                        res_arr(cycleNum) = res;
                        File.Data(channel_idx).Resistance = res_arr;
                        % regression
                        r2_arr = File.Data(channel_idx).Regression;
                        r2_arr(cycleNum) = r2;
                        File.Data(channel_idx).Regression = r2_arr;
                        % plot
                        set(0,'CurrentFigure',ivPlot);
                        trendline(channel_idx) = plot(xRange,trend, ...
                            'Color',color, ...
                            'LineStyle',':', ...
                            'LineWidth',1, ...
                            'HandleVisibility','off');
                        equation_str = sprintf( ...
                            '{\\bf{\\ity}} = %.4g{\\bf{\\itx}} + %.4g', ...
                            slope,intercept);
                        reg_str = sprintf( ...
                            '{\\bf{\\itr}^{2}} = %.4g', ...
                            r2);
                        %                     end

                        if numOfCycles > 1
                            cycleNum_name = sprintf('Cycle %d',cycleNum);
                            legend_arr_alloc = [cycleLegend_cell;cycleNum_name];
                            cycleLegend_cell = legend_arr_alloc;
                            legend(cycleLegend_cell,'Location','best');
                            if contains2(expID,'CAP') && isCycleDone
                                annot_text{cycleNum,channel_idx} = sprintf( ...
                                    '{\\bfCycle %d}\n%s\n%s\n%s\n%s', ...
                                    cycleNum, ...
                                    equation_str, ...
                                    reg_str, ...
                                    res_char, ...
                                    cap_str);
                            else
                                annot_text{cycleNum,channel_idx} = sprintf( ...
                                    '{\\bfCycle %d}\n%s\n%s\n%s', ...
                                    cycleNum, ...
                                    equation_str, ...
                                    reg_str, ...
                                    res_char);
                            end
                        else
                            if contains2(expID,'CAP') && isCycleDone
                                annot_text = sprintf( ...
                                    '%s\n%s\n%s\n%s', ...
                                    equation_str, ...
                                    reg_str, ...
                                    res_char, ...
                                    cap_str);
                            else
                                annot_text = sprintf( ...
                                    '%s\n%s\n%s', ...
                                    equation_str, ...
                                    reg_str, ...
                                    res_char);
                            end
                            annot_text_cell{cycleNum} = annot_text;
                        end
                        annot(cycleNum,channel_idx) = annotation( ...
                            ivPlot, ...
                            'textbox',ANNOT_DIM, ...
                            'String',annot_text_cell, ...
                            'FontSize',FONT_SIZE-8, ...
                            'FitBoxToText','on');
                    end
                    annot_text_cell{cycleNum} = annot_text;
                end
                drawnow;
                hold off;
            end
        end
    end
    
    %% Disconnect with Keithley
    if quitExp
        fprintf('OK\n\n');
        setVoltageBias2(File,0); % reset voltage bias
        setSource2(File,'off');
        fprintf('\n');
        return;
    else
        setVoltageBias2(File,0); % reset voltage bias
        setSource2(File,'off');
        fprintf('\n');
    end

    % End date and time
    [endTime,unit] = getEndTime(startTime);
%     endTime_s = toc(startTime);
    dateTimeEnd = getDateTime();
    fprintf('%s completed in: %.2f %s\n',expID,endTime,unit);

    % Store data to I-V structure
    for channel_idx = 1:channelSelect_len
        channelCurrentSteps_arr = current_matrix(stepNum_arr,channel_idx);
        %     if contains2(expID,{'CAP','STEP'})
        %         voltageStep = File.Experiment.Parameters.VoltageStep;
        %         timeStep = File.Experiment.Parameters.TimeStep;
        %     end
        File.Data(channel_idx).Voltage = voltageSteps_arr;
        File.Data(channel_idx).Current = channelCurrentSteps_arr;
        File.Data(channel_idx).DateTimeStart = dateTimeStart;
        File.Data(channel_idx).DateTimeEnd = dateTimeEnd;
    end
    try
        File.Data = rmfield(File.Data,'StepData');
    catch
    end
    try
        File.StepData = rmfield(File.StepData,'Statistics');
    catch
    end

    %% Save I-V data
    if ~contains(expID,'IT')
        [iv_mat,iv_xlsx,iv_tif] = saveIV2(File,ivFig_arr);
        dataFiles = {iv_mat,iv_xlsx};
        emailFiles = [dataFiles,iv_tif];
        fprintf('\n');
    end

    %% Email
    if ~isempty(emailAddress)
        endTime_use = {endTime,unit};
        sendEmail2(expID,subjectName,emailAddress,emailFiles,endTime_use);
        fprintf('\n');
    end

catch err
    beep;pause(0.1);beep;pause(0.1);beep;pause(0.1);beep;
    File.Error.Status = err;
    report = getReport(err);
    File.Error.Report = report;
    display(report);
    quitExp = true;
end
fprintf('\n');

end