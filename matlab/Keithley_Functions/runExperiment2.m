function [File,shareFiles] = runExperiment2(File)

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
LINE_STYLE = {'-','--',':','-.'};
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
ANNOT_DIM = [.75 .65 .2 .2];
FONT_SIZE = 20;
FIG_WIDTH = 960;
FIG_HEIGHT = 720;

%% Variables
expID = File.Experiment.ID;
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
        numOfSweeps = File.Experiment.Parameters.Sweeps;
end

% Measurement
if strcmpi(expID,'it')
    voltageList = File.Experiment.Parameters.VoltageBias;
else
    voltageList = File.Experiment.Parameters.VoltageList;
    numOfSteps = File.Experiment.Parameters.NumberOfSteps;
    current_matrix = zeros(numOfSteps,channelSelect_len);
    voltageStep = File.Experiment.Parameters.VoltageStep;
end
if strcmpi(expID,'CAP') || strcmpi(expID,'STEP')
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
if ~strcmpi(expID,'it')
    ivFig_arr = createWindow('windowIV',channelSelect_len,channelNameList);
    cycleLegend_cell = {};
end

setSource3(File,'on');                     % turn on source
startTime = tic;
dateTimeStart = getDateTime();
for stepNum = 1:numOfSteps
    voltageBias = voltageList(stepNum);
    if numOfCycles == 1
        cycleNum = 1;
    else
        if ismember(stepNum,cycleStart_array)
            cycleNum = find(cycleStart_array == stepNum);
        end
    end

    if ~strcmpi(expID,'it')
        File.StepData(stepNum).Step = stepNum;
        File.StepData(stepNum).VoltageBias = voltageBias;
        File.StepData(stepNum).Data = initStruct2('it');
        for channel_idx = 1:channelSelect_len
            channelName = channelNameList(channel_idx);
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
    [File,itPlot] = runIT4(File);
    quitExp = File.Experiment.Quit;
    if quitExp == true                             % stop experiment
        fprintf('OK.\n\n');
    end

    %% Save I-T Data
    % Spreadsheet
    [~,~] = saveIT(File,itPlot);
    fprintf('\n');
    if quitExp == true
        return;
    end

    %% Store I-V Data
    if ~strcmpi(expID,'IT')
        % Steady-state current
%         if strcmpi(expID,'IV')
%             processed_arr = File.Instrument.Processing(stepNum).Values;
%             current_matrix(stepNum,:) = processed_arr;
%         end

        %% Check Cycle
        stepNum_arr = 1:stepNum;
        presentCycle_idx = cycleList{cycleNum};
        presentCycleStart_idx = presentCycle_idx(1);
        presentStep_idx = presentCycleStart_idx:stepNum;
        isCycleDone = isequal(presentCycle_idx,stepNum_arr);

        %% I-V Plot
        annot = gobjects(numOfCycles,channelSelect_len); %#ok<*NASGU>
        trendline = gobjects(channelSelect_len,1);
        %         delete(findall(ivFig_arr,'type','annotation'))
        lowerLimit = min(voltageList);
        upperLimit = max(voltageList);
        for channel_idx = 1:channelSelect_len
            % Figure
            annot_text_cell = cell(numOfCycles,1);
            channelName = channelNameList(channel_idx);
            ivPlot = figure(ivFig_arr(channel_idx));
            clf;
            ax = gca;
            % Plot values
            if strcmpi(expID,'IV')
                channelCurrentSteps_arr = current_matrix(stepNum_arr,channel_idx);
            else
                channelCurrentStep = File.StepData(stepNum).Data(channel_idx).Statistics.Mean;
                current_matrix(stepNum,channel_idx) = channelCurrentStep;
                channelCurrentSteps_arr = current_matrix(stepNum_arr,channel_idx);
            end
            voltageSteps_arr = voltageList(stepNum_arr);
            color = MATLAB_COLOR{channel_idx};
            lineStyle = LINE_STYLE{cycleNum};
            marker = MARKER_TYPE{channel_idx};
            plot(voltageSteps_arr,channelCurrentSteps_arr,...
                'Color',color,...
                'LineStyle',lineStyle,...
                'Marker',marker,...
                'MarkerSize',10,...
                'MarkerFaceColor',color,...
                'MarkerEdgeColor',color); %#ok<*SAGROW>
            hold on;

            % Labels
            set(ax,'FontSize',FONT_SIZE);
            %             set(fig,...
            %                 'position',[screenWidth,screenHeight,FIG_WIDTH,FIG_HEIGHT]);
            % titles
            if lowerLimit == 0 || upperLimit == 0
                ivPlot_title = sprintf('Current vs. Voltage: %.2f to %.2f V',lowerLimit,upperLimit);
            elseif lowerLimit == 0
                ivPlot_title = sprintf('Current vs. Voltage: %.2f to %+.2f V',lowerLimit,upperLimit);
            elseif upperLimit == 0
                ivPlot_title = sprintf('Current vs. Voltage: %+.2f to %.2f V',lowerLimit,upperLimit);
            else
                ivPlot_title = sprintf('Current vs. Voltage: %+.2f to %+.2f V',lowerLimit,upperLimit);
            end
            title(ivPlot_title);
            ivPlot_subtitle = sprintf('Channel: %s',channelName);
            subtitle(ivPlot_subtitle);
            % axes
            xlabel('Voltage (V)');
            ylabel('Current (A)');
            xMin = lowerLimit - 2*voltageStep;
            xMax = upperLimit + 2*voltageStep;
            xlim([xMin xMax]);
            ytickformat('%.2g');


            if stepNum > 1
                if ~strcmpi(expID,'STEP')
                    % Capacitance
                    if strcmpi(expID,'CAP') && isCycleDone
                        [cap,cap_str] = getCapacitance(voltageSteps_arr,channelCurrentSteps_arr,voltageStep,timeStep);
                        File.Data(channel_idx).Capacitance = cap(cycleNum);
                    end
                    % Resistance
                    % bounds
                    xBounds_min = min(voltageList) - voltageStep;
                    xBounds_max = max(voltageList) + voltageStep;
                    xRange = xBounds_min:xBounds_max;
                    % trendline
                    presentX = voltageList(presentStep_idx);
                    presentY = channelCurrentSteps_arr(presentStep_idx);
                    [slope,intercept,r2] = getLinReg(presentX,presentY);
                    trend = polyval([slope intercept],xRange);
%                     isSlopeFit = r2 > 0.8;  % coefficient of determination
%                     if isSlopeFit
                        [res,res_str]= getResistance(slope);
                        try
                            res_arr = File.Data(channel_idx).Resistance;
                        catch
                            res_arr = res;
                        end
                        res_arr_alloc = [res_arr,res];
                        File.Data(channel_idx).Resistance = res_arr_alloc;
                        r2_arr = File.Data(channel_idx).Regression;
                        r2_arr_alloc = [r2_arr,r2];
                        File.Data(channel_idx).Regression = r2_arr_alloc;

                        set(0,'CurrentFigure',ivPlot);
                        trendline(channel_idx) = plot(xRange,trend,...
                            'Color','k',...
                            'LineStyle',lineStyle,...
                            'LineWidth',1);
                        equation_str = sprintf(...
                            '{\\bf{\\ity}} = %.4g{\\bf{\\itx}} + %.4g',...
                            slope,intercept);
                        reg_str = sprintf(...
                            '{\\bf{\\itr}^{2}} = %.4g',...
                            r2);
%                     end

                    if numOfCycles > 1
                        cycleNum_name = sprintf('Cycle %d',cycleNum);
                        legend_arr_alloc = [cycleLegend_cell;cycleNum_name];
                        cycleLegend_cell = legend_arr_alloc;
                        legend(cycleLegend_cell,'Location','best');
                        if strcmpi(expID,'CAP') && isCycleDone
                            annot_text{cycleNum,channel_idx} = sprintf(...
                                '{\\bfCycle %d}\n%s\n%s\n%s\n%s',...
                                cycleNum,...
                                equation_str,...
                                reg_str,...
                                res_str,...
                                cap_str);
                        else
                            annot_text{cycleNum,channel_idx} = sprintf(...
                                '{\\bfCycle %d}\n%s\n%s\n%s',...
                                cycleNum,...
                                equation_str,...
                                reg_str,...
                                res_str);
                        end
                    else
                        if strcmpi(expID,'CAP') && isCycleDone
                            annot_text = sprintf(...
                                '%s\n%s\n%s\n%s',...
                                equation_str,...
                                reg_str,...
                                res_str,...
                                cap_str);
                        else
                            annot_text = sprintf(...
                                '%s\n%s\n%s',...
                                equation_str,...
                                reg_str,...
                                res_str);
                        end
                        annot_text_cell{cycleNum} = annot_text;
                    end
                    annot(cycleNum,channel_idx) = annotation(...
                        ivPlot,...
                        'textbox',ANNOT_DIM,...
                        'String',annot_text_cell,...
                        'FontSize',FONT_SIZE-8,...
                        'FitBoxToText','on');
                end
                annot_text_cell{cycleNum} = annot_text;
            end
            hold off;
        end
    end
end
%         clc;

% End date and time
endTime = toc(startTime);
dateTimeEnd = getDateTime();
fprintf('I-V measurement completed in: %f s',endTime);

% Store data to I-V structure
for channel_idx = 1:channelSelect_len
    channelCurrentSteps_arr = current_matrix(stepNum_arr,channel_idx);
%     if strcmpi(expID,'CAP') || strcmpi(expID,'STEP')
%         voltageStep = File.Experiment.Parameters.VoltageStep;
%         timeStep = File.Experiment.Parameters.TimeStep;
%     end
    File.Data(channel_idx).Voltage = voltageSteps_arr;
    File.Data(channel_idx).Current = channelCurrentSteps_arr;
    File.Data(channel_idx).DateTimeStart = dateTimeStart;
    File.Data(channel_idx).DateTimeEnd = dateTimeEnd;
end

%% Save I-V data
[~,iv_xlsx] = saveIV2(File,ivFig_arr);
shareFiles = iv_xlsx;
fprintf('\n');

end