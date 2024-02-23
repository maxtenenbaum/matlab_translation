clear; clc; close all;
warning('off','all');

try
    delete(findall(groot,'Type','figure'));
catch
end
close all; clc; clear;
warning('off','all');
fprintf('PROGRAM STARTED\n\n');

%% Constants
% Values
FAIL_THRESH = 100e9;
TERA = 1e12;
GIGA = 1e9;
MEGA = 1e6;
ANNOT_DIM = [.15 .65 .2 .2];
REG_THRESH = 0.0;
BESSEL = 0; % n - 1
TEST_THRESH = 3;

EXP_FILE = 'IV';
LINREG_SLOPE_IDX = 1;       % index for slope in polyfit
LINREG_INTERCEPT_IDX = 2;   % index for y-intercept in polyfit

% Plot
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
TRIPLET = 3;
FONT_SIZE = 20;

% Button
BUTTON_D1 = 'Done';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
BUTTON_QUIT = 'Quit';
% Dialog
CHECK_TITLE = 'ERROR';
READ_TITLE = 'Confirmation';
% Options
opts.Default = 'yes';       % option default
opts.Interpreter = 'tex';   % option LaTeX

% Figure
FIG_WIDTH = 960;
FIG_HEIGHT = 720;
WINDOW_HEADER = 80;
FIG_POS_X = 1;
FIG_SHIFT = 20; %#ok<NASGU>

%% Variables
retrieving = 1;
filesInUse = strings();
voltage_cell = {};
current_cell = {};
% Linear regression
slope_arr = [];
intercept_arr = [];
reg_arr = [];
res_arr = [];
sampleSize = 0;

% Failure
if (FAIL_THRESH/TERA) > 1
    coeff = FAIL_THRESH / TERA;
    fail_char = sprintf('%g T',coeff);
elseif (FAIL_THRESH/GIGA) > 1
    coeff = FAIL_THRESH / GIGA;
    fail_char = sprintf('%g G',coeff);
elseif (FAIL_THRESH/MEGA) > 1
    coeff = FAIL_THRESH / MEGA;
    fail_char = sprintf('%g M',coeff);
end

% Screen
screenSize = get(0,'screensize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

% Figure
voltageFailure_array = [];
timeFailure_array = [];
figPosY = screenHeight - FIG_HEIGHT - WINDOW_HEADER;
FIG_SHIFT = 20;

%% Find functions folder
findFunctions();

%% Import data
fprintf('Retrieving data...\n');
while retrieving == true
    [filesSel,path] = uigetfile('*.mat','MultiSelect','on');
    if isa(filesSel,'double') == true
        files = filesSel;
    else
        files = cellstr(filesSel);
    end
    numOfFile = length(files);
    for file_idx = 1:numOfFile
        try
            file = files{file_idx};
        catch
            file = 0;
        end
        if file ~= 0
            alreadyUsed = any(contains(filesInUse,file));
        end
        if file == 0
            fprintf('Checking...');
            emptySelection = '{\bfINCORRECT INPUT}';
            check_quest = questdlg(emptySelection,CHECK_TITLE,BUTTON_D1,BUTTON_TRY,BUTTON_QUIT,opts);
            switch check_quest                  	% apply choice
                case BUTTON_D1                 	% check confirmation
                    fprintf('D1...');
                    retrieving = 0;
                    fprintf('OK\n');
                    break;                          % done
                case BUTTON_TRY                     % try again
                    fprintf('Trying again...\n');   % starting over
                    break;
                case BUTTON_QUIT                    % quit
                    fprintf('Quitting...');         % quitting
                    fprintf('OK\n\n');
                    return;                         % exit program
                otherwise                           % cancel
                    fprintf('Quitting...\n\n'); 	% quitting
                    return;                         % exit program
            end
        elseif alreadyUsed == true
            sameFile = 'File already added.';
            check_quest = questdlg(sameFile,CHECK_TITLE,BUTTON_D1,BUTTON_TRY,BUTTON_QUIT,opts);
            switch check_quest                  	% apply choice
                case BUTTON_D1                 	% check confirmation
                    break;                          % done
                case BUTTON_TRY                     % try again
                    fprintf('Trying again...\n');   % starting over
                    continue;
                case BUTTON_QUIT                    % quit
                    fprintf('Quitting...');         % quitting
                    fprintf('OK\n\n');
                    return;                         % exit program
                otherwise                           % cancel
                    fprintf('Quitting...\n\n'); 	% quitting
                    return;                         % exit program
            end
        else
            fprintf('Selecting "%s"...',file);
            fprintf('Loading...');
            filename = fullfile(path,file);
            load(filename);
            folder = path;
            
            % Parameters
            fprintf('Processing...');
            voltage_ = structIV(1).Voltage;
            minVoltage = min(voltage_);
            maxVoltage = max(voltage_);
            stepSize = voltage_(2) - voltage_(1);
            
            file_use = sprintf('File: {\\bf%s}',file);
            file_use = strrep(file_use,'_','\_');
            voltageRange_use = sprintf('Voltage range (V): {\\bf%+.2f} to {\\bf%+.2f}',minVoltage,maxVoltage);
            stepSize_use = sprintf('Step size (V): {\\bf%g}',stepSize);
            fprintf('OK\n');
            
            read_prompt = {...
                file_use,...
                voltageRange_use,...
                stepSize_use};
            
            confirmFile = 1;                % confirm
%             read_quest = questdlg(read_prompt,READ_TITLE,BUTTON_CONFIRM,BUTTON_TRY,BUTTON_QUIT,opts);
%             confirmFile = 0;
%             switch read_quest                       % apply choice
%                 case BUTTON_CONFIRM                 % check confirmation
%                     confirmFile = 1;                % confirm
%                     fprintf('OK\n');               % parameters confirmed
%                 case BUTTON_TRY                     % try again
%                     fprintf('Trying again...\n');   % starting over
%                     break;
%                 case BUTTON_QUIT                    % quit
%                     fprintf('Quitting...\n\n');  	% quitting
%                     return;                         % exit program
%                 otherwise                           % cancel
%                     fprintf('Quitting...\n\n'); 	% quitting
%                     return;                         % exit program
%             end

            if confirmFile == true
                filesInUse_alloc = [filesInUse;file];
                filesInUse = filesInUse_alloc;
                emptyIndx = find(filesInUse == '');
                filesInUse(emptyIndx) = [];
                [~,numOfChannels] = size(structIV);
                for channelNum = 1:numOfChannels
                    channelName = structIV(channelNum).Channel;
                    fprintf('Processing %s...',channelName);

                    % Plot values
                    current = structIV(channelNum).Current;
                    voltage = structIV(channelNum).Voltage;
                    [current_fix,voltage_fix,~] = getNoOverflow(current,voltage,0);

                    linReg = polyfit(voltage_fix,current_fix,1);
                    % trendline
                    slope = linReg(LINREG_SLOPE_IDX);
                    intercept = linReg(LINREG_INTERCEPT_IDX);
                    % resistance
                    res = abs(1 / slope);
                    % coefficient of determination
                    linEval_row = polyval(linReg,voltage_fix);
                    num = sum((current_fix - linEval_row).^2);
                    den = sum((current_fix - mean(current_fix)).^2);
                    reg = max(1 - num/den);

                    if reg > REG_THRESH
                        voltage_cell_alloc = [voltage_cell;voltage];
                        voltage_cell = voltage_cell_alloc;
                        current_cell_alloc = [current_cell;current];
                        current_cell = current_cell_alloc;
                        slope_arr_alloc = [slope_arr,slope];
                        slope_arr = slope_arr_alloc;
                        intercept_arr_alloc = [intercept_arr,intercept];
                        intercept_arr = intercept_arr_alloc;
                        reg_arr_alloc = [reg_arr,reg];
                        reg_arr = reg_arr_alloc;
                        res_arr_alloc = [res_arr,res];
                        res_arr = res_arr_alloc;
                        sampleSize = sampleSize + 1;
                    else
                        fprintf('Skipping...');
                    end
                    fprintf('OK\n');
                end
            end
            fprintf('\n');
        end
    end
end

%% Save
% fprintf('Select save folder...');
% folder = uigetdir(folder,'Save Folder');
% if folder == 0
%     fprintf('PROGRAM ENDED\n\n');
%     return;
% else
%     fprintf('OK\n');
% end
try
    name = input('Enter save name: ','s');
catch
    fprintf('PROGRAM ENDED\n\n');
    return;
end
fprintf('\n');

%% Statistics
stats = [slope_arr;intercept_arr;reg_arr;res_arr];
samples = 1:sampleSize;

% Normality test
[isResNorm,isResLognorm,isResWeibull] = getDistribution(res_arr,'Data');
logRes_arr = log10(res_arr);

% Descriptive statistics
% range
resMin = min(res_arr);
resMax = max(res_arr);
% mean
resMean = mean(res_arr,'all');
resMean_ord = floor(log10(resMean));
resMean_coeff = resMean / (10^resMean_ord);
resSTD = std(res_arr,BESSEL,'all');
% standard deviation
resSTD_ord = floor(log10(resSTD));
resSTD_coeff = resSTD / (10^resMean_ord);
% display
fprintf('Sample size: %d\n',sampleSize);
fprintf('Sample minimum: %g Ohm\n',resMin);
fprintf('Sample maximum: %g Ohm\n',resMax);
fprintf('Sample mean: %g Ohm\n',resMean);
fprintf('Sample standard deviation: %g Ohm\n',resSTD);
fprintf('\n');

% Failed
fprintf('Detecting failed (<%sOhm)...',fail_char);
failed_idx = find(res_arr < FAIL_THRESH);
res_arr_failed = res_arr(failed_idx);
samples_failed = samples(failed_idx);
numOfFailed = length(failed_idx);
fprintf('%d\n',numOfFailed);

% Outlier
% normal
% fprintf('Detecting normal outliers...');
linResOutlier_idx = isoutlier(res_arr,'quartiles');
numOfLinOutliers = nnz(linResOutlier_idx);
% fprintf('%d\n',numOfLinOutliers);
% log
fprintf('Detecting logarithmic outliers...');
logResOutlier_idx = isoutlier(logRes_arr,'median');
numOfLogOutliers = nnz(logResOutlier_idx);
fprintf('%d\n',numOfLogOutliers);
% total
% resOutlier_idx = xor(linResOutlier_idx,logResOutlier_idx);
resOutlier_idx = logResOutlier_idx;
res_arr_outlier = res_arr(resOutlier_idx);
samples_outlier = samples(resOutlier_idx);
numOfOutliers = nnz(resOutlier_idx);

% Exclusion
fprintf('Total exluded data points: ');
resOutlier_idx = find(resOutlier_idx);
resExclude_idx = unique([resOutlier_idx,failed_idx]);
numOfExclude = length(resExclude_idx);
res_arr_fix = res_arr;
res_arr_fix(resExclude_idx) = [];
sampleSize_fix = sampleSize - numOfExclude;
samples_fix = samples;
samples_fix(resExclude_idx) = [];
fprintf('%d\n',numOfExclude);
fprintf('\n');

% Fixed normality
[isResNorm_fix,isResLognorm_fix,isResWeibull_fix] = getDistribution(res_arr_fix,'Fixed data');

% Fixed descriptive statistics
% median
resMed_fix = median(res_arr_fix);
% range
resMin_fix = min(res_arr_fix);
resMax_fix = max(res_arr_fix);
resLowQuantile_fix = quantile(res_arr_fix,0.25);
resHighQuantile_fix = quantile(res_arr_fix,0.75);
% mean
resMean_fix = mean(res_arr_fix,'all');
resMean_fix_ord = floor(log10(resMean_fix));
resMean_fix_coeff = resMean_fix / (10^resMean_fix_ord);
% standard deviation
resSTD_fix = std(res_arr_fix,BESSEL,'all');
resSTD_fix_ord = floor(log10(resSTD_fix));
resSTD_fix_coeff = resSTD_fix / (10^resSTD_fix_ord);
% display
fprintf('Fixed sample size: %d\n',sampleSize_fix);
fprintf('Fixed sample minimum: %g Ohm\n',resMin_fix);
fprintf('Fixed sample maximum: %g Ohm\n',resMax_fix);
fprintf('Fixed sample mean: %g Ohm\n',resMean_fix);
fprintf('Fixed sample standard deviation: %g Ohm\n',resSTD_fix);
fprintf('\n');

%% Scatter Plot
data_array = [res_arr_fix,res_arr_outlier,res_arr_failed];
data_bad = [res_arr_outlier,res_arr_failed];
scatterTitle = sprintf('Resistance ({\\itn} = %d)',sampleSize);
% scatterSubtitle = sprintf('{\\bf\\itR} = %.4g \\pm %.4g {\\bf\\Omega}',resMean,resSTD);
scatterSubtitle = sprintf(...
    '{\\bf\\itR} = %.4g\\times10^{%g} \\pm %.4g\\times10^{%g} {\\bf\\Omega}',...
    resMean_coeff,resMean_ord,resSTD_coeff,resSTD_ord);

% Linear
fprintf('Generating scatter plot...');
scatterFig = figure('Name','Scatter Plot');
scatterChart = plot(samples_fix,res_arr_fix,...
    'LineStyle','none',...
    'Marker','o',...
    'MarkerFaceColor','k',...
    'MarkerSize',5,...
    'Color','k');
hold on;
scatterChart_outlier = plot(samples_outlier,res_arr_outlier,...
    'LineStyle','none',...
    'Marker','+',...
    'MarkerSize',10,...
    'Color','b');
scatterChart_exclude = plot(samples_failed,res_arr_failed,...
    'LineStyle','none',...
    'Marker','x',...
    'MarkerSize',10,...
    'Color','r');
box on;
ylim('tickaligned');
xlim('padded');
set(gca,'xtick',[]);
hold on;
set(scatterFig,'Position',[FIG_POS_X,figPosY,FIG_WIDTH,FIG_HEIGHT]);
title(scatterTitle);
subtitle(scatterSubtitle);
ylabel('Resistance (\Omega)');
fail_name = sprintf('<%s\\Omega',fail_char);
fail_name = strrep(fail_name,'+','');
if ~isempty(data_bad)
    legend_arr = {'Fixed Data','Outlier',fail_name};
    legend(legend_arr,'Location','best');
end
set(gca,'FontSize',FONT_SIZE);
fprintf('OK\n');

% Export
scatterFilename = sprintf('%s_Scatter_Res.tif',name);
scatterFilepath = fullfile(folder,scatterFilename);
exportPlot(scatterFig,scatterFilepath,400);
set(gca,'YScale','log');
yMax = max(data_array);
yMin = min(data_array);
yMax_pow = floor(log10(yMax));
yMin_pow = floor(log10(yMin));
% yMax_coeff = yMax / yMax_pow;
% yMin_coeff = yMin / yMin_pow;
yMax_new = 10^(yMax_pow+1);
yMin_new = 10^yMin_pow;
ylim([yMin_new yMax_new]);
% ylim('tickaligned');
if ~isempty(data_bad)
    legend(legend_arr,'Location','best');
end
logScatterFilename = sprintf('%s_Scatter_LogRes.tif',name);
logScatterFilepath = fullfile(folder,logScatterFilename);
exportPlot(scatterFig,logScatterFilepath,400);
fprintf('\n');


%% Box Plot
fprintf('Generating box plot...');
boxTitle = sprintf('Resistance ({\\itn} = %d)',sampleSize_fix);
% boxSubtitle = sprintf('{\\bf\\itR} = %.4g \\pm %.4g {\\bf\\Omega}',resMean_fix,resSTD_fix);
boxSubtitle = sprintf(...
    '{\\bf\\itR} = %.4g\\times10^{%g} \\pm %.4g\\times10^{%g} {\\bf\\Omega}',...
    resMean_fix_coeff,resMean_fix_ord,resSTD_fix_coeff,resSTD_fix_ord);
boxWidth = 0.25;
boxColor = 'k';
lineColor = 'k';
boxAlpha = 0;
lineWidth = 1.5;
markerStyle = '+';
markerSize = 10;
markerColor = 'k';

boxFig = figure('Name','Box Plot');
boxChart = boxchart(res_arr_fix,...
    'BoxWidth',boxWidth,...
    'BoxFaceColor',boxColor,...
    'WhiskerLineColor',lineColor,...
    'BoxFaceAlpha',boxAlpha,...
    'LineWidth',lineWidth,...
    'MarkerStyle',markerStyle,...
    'MarkerSize',markerSize,...
    'MarkerColor',markerColor);
box on;
ylim('tickaligned');
set(gca,'xtick',[]);
hold on;
figPosX_new = FIG_POS_X + FIG_SHIFT;
figPosY_new = figPosY - FIG_SHIFT;
set(boxFig,'Position',[figPosX_new,figPosY_new,FIG_WIDTH,FIG_HEIGHT]);
title(boxTitle);
subtitle(boxSubtitle);
ylabel('Resistance (\Omega)');
set(gca,'FontSize',FONT_SIZE);
fprintf('OK\n');

% Export
boxFilename = sprintf('%s_BoxPlot_Res_annot.tif',name);
boxFilepath = fullfile(folder,boxFilename);
exportPlot(boxFig,boxFilepath,400);

% Export
set(gca,'YScale','log');
yRange = ylim;
yMin = yRange(1);
yMax = yRange(2);
yMin_ord = floor(log10(yMin));
yMax_ord = ceil(log10(yMax));
yMin_log = 10^yMin_ord;
yMax_log = 10^yMax_ord;
ylim([yMin_log yMax_log]);
boxFilename = sprintf('%s_BoxPlot_LogRes_annot.tif',name);
boxFilepath = fullfile(folder,boxFilename);
exportPlot(boxFig,boxFilepath,400);
fprintf('\n');

% Export
title('');
subtitle('');
boxFilename = sprintf('%s_BoxPlot_LogRes.tif',name);
boxFilepath = fullfile(folder,boxFilename);
exportPlot(boxFig,boxFilepath,400);
fprintf('\n');

% Export
set(gca,'YScale','linear');
ylim('tickaligned');
boxFilename = sprintf('%s_BoxPlot_Res.tif',name);
boxFilepath = fullfile(folder,boxFilename);
exportPlot(boxFig,boxFilepath,400);
fprintf('\n');

%% Program End
fprintf('PROGRAM ENDED\n\n');

%% findFunctions
function [] = findFunctions()

functionsCKN = 'Z:\2_ Projects and Data\0_ Personal Folders\Christopher Nguyen\MATLAB\CKN_Functions';
path(path,functionsCKN);

functionFolder = 'Analysis_Functions';                      % function folder name
functions_location_Cdrive = 'C:\Analysis_Functions';        % function folder in :C
folderExists = 7;                                           % folder existing value
fprintf('Searching for Function Folder in directory...');   % searching for SDK
if exist(functionFolder,'dir') == folderExists          % functions found in directory
    fprintf('OK\n\n');                                 % functions found
    path(path,functionFolder);                          % adding functions to path (just in case)
else                                                            % functions not found
    prompt = 'FUNCTIONS NOT FOUND IN DIRECTORY';             	% message prompt
    waitfor(msgbox(prompt,titleError));                         % functions not found in directory
    fprint('NOT FOUND\n');
    fprintf('Searching for Funtion Folder in :C...') ;          % searching for Funtion Folder in C:
    if exist(functions_location_Cdrive,'dir') == folderExists 	% functions found
        fprintf('OK\n\n');                                     % functions found in C:
        path(path,functions_location_Cdrive);                	% adding Ffunctions to directory
    else                                                      	% functions not found
        fprintf('NOT FOUND\n');                                % functions not found in C:
        prompt1 = 'Find Funtion Folder to add to directory.';   % select folder into directory
        prompt2 = sprintf('"%s"',functionFolder);            	% folder to find
        disp(prompt1);                                      	% print message
        waitfor(msgbox({prompt1,prompt2},titleError));       	% message box
        functions_location = uigetdir();                    	% input folder location
        cancel_functions_location = isempty(functions_location);% ccncel dialog
        if cancel_functions_location == true	% cancel detected
            fprintf('\nQuitting...\n\n');  	% quitting
            return;                       	% exit program
        else                                   	% path entered
            fprintf('\nFuntions located\n\n'); % path located
            path(path,functions_location);    	% adding Funtion Folder to directory
        end
    end
end

end