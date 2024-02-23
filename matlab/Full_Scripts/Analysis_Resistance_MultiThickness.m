try
    clear; clc; close all;
catch
    delete(findall(groot,'Type','figure'));
end
warning('off','all');
fprintf('PROGRAM STARTED.\n\n');

%% Constants
% Values
FAIL_THRESH = 100e9;
TERA = 1e12;
GIGA = 1e9;
MEGA = 1e6;
ANNOT_DIM = [.15 .70 .2 .2];
REG_THRESH = 0.0;

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
BUTTON_DONE = 'Done';
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
FIG_SHIFT = 20;

%% Variables
retrieving = 1;
filesInUse = strings();

% Compile
dist_cell_fix = {};
slope_cell = {};
intercept_cell = {};
reg_cell = {};
res_cell = {};
sampleSize_arr = [];
depThick_arr_um = [];
                        
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
figPosY = screenHeight - FIG_HEIGHT - WINDOW_HEADER;

% Figure
voltageFailure_array = [];
timeFailure_array = [];

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
    sampleSize = 0;
    % Linear regression
    slope_arr = [];
    intercept_arr = [];
    reg_arr = [];
    res_arr = [];
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
            check_quest = questdlg(emptySelection,CHECK_TITLE,BUTTON_DONE,BUTTON_TRY,BUTTON_QUIT,opts);
            switch check_quest                  	% apply choice
                case BUTTON_DONE                 	% check confirmation
                    fprintf('DONE...');
                    retrieving = 0;
                    fprintf('OK.\n');
                    break;                          % done
                case BUTTON_TRY                     % try again
                    fprintf('Trying again...\n');   % starting over
                    break;
                case BUTTON_QUIT                    % quit
                    fprintf('Quitting...');         % quitting
                    fprintf('OK.\n\n');
                    return;                         % exit program
                otherwise                           % cancel
                    fprintf('Quitting...\n\n'); 	% quitting
                    return;                         % exit program
            end
        elseif alreadyUsed == true
            sameFile = 'File already added.';
            check_quest = questdlg(sameFile,CHECK_TITLE,BUTTON_DONE,BUTTON_TRY,BUTTON_QUIT,opts);
            switch check_quest                  	% apply choice
                case BUTTON_DONE                 	% check confirmation
                    break;                          % done
                case BUTTON_TRY                     % try again
                    fprintf('Trying again...\n');   % starting over
                    continue;
                case BUTTON_QUIT                    % quit
                    fprintf('Quitting...');         % quitting
                    fprintf('OK.\n\n');
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
%                     fprintf('OK.\n');               % parameters confirmed
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

                    
                    % Linear regression
                    [slope,intercept,r2]= getLinReg(voltage_fix,current_fix);
                    [res,~,~] = getResistance(slope);
                    if r2 > REG_THRESH
                        slope_arr_alloc = [slope_arr,slope];
                        slope_arr = slope_arr_alloc;
                        intercept_arr_alloc = [intercept_arr,intercept];
                        intercept_arr = intercept_arr_alloc;
                        reg_arr_alloc = [reg_arr,r2];
                        reg_arr = reg_arr_alloc;
                        res_arr_alloc = [res_arr,res];
                        res_arr = res_arr_alloc;
                        sampleSize = sampleSize + 1;
                    else
                        fprintf('Skipping...');
                    end
                    fprintf('OK.\n');
                end
            end
            fprintf('\n');
        end
    end
    
    if retrieving == true
        dep_thick_um = input('Enter thickness (um): ');
        fprintf('\n');
        if ~ismember(dep_thick_um,depThick_arr_um)
            depThick_arr_um_alloc = [depThick_arr_um,dep_thick_um];
            depThick_arr_um = depThick_arr_um_alloc;
            numOfThickness = length(depThick_arr_um);
        end
        
        slopeCell_arr_alloc = [slope_cell,slope_arr];
        slope_cell = slopeCell_arr_alloc;
        interceptCell_arr_alloc = [intercept_cell,intercept_arr];
        intercept_cell = interceptCell_arr_alloc;
        regCell_arr_alloc = [reg_cell,reg_arr];
        reg_cell = regCell_arr_alloc;
        resCell_arr_alloc = [res_cell,res_arr];
        res_cell = resCell_arr_alloc;
        sampleSize_arr_alloc = [sampleSize_arr,sampleSize];
        sampleSize_arr = sampleSize_arr_alloc;
    end
end

%% Save
saveFig = input('Enter 1 to save figures, 0 otherwise: ');

if saveFig == true
    fprintf('Select save folder...');
    folder = uigetdir('Save Folder');
    if folder == 0
        fprintf('PROGRAM ENDED.\n\n');
        return;
    else
        fprintf('"%s"\n',folder);
    end

    try
        name = input('Enter save name: ','s');
    catch
        fprintf('PROGRAM ENDED.\n\n');
        return;
    end
end
fprintf('\n');

%% Resistivity
% Conversion
MICRO_TO_MILLI = 1e-3;
NANO_TO_MILLI = 1e-6;
MILLI_TO_CENTI = 1e-1;

% Dimensions
NUM_OF_FINGERS = 54;
GAP_UM = 30;            % gap
FINGER_LENGTH_UM = 2200;
WIDTH_TOP_UM = 120;
WIDTH_SIDE_UM = 180;
metal_nm = input('Enter metal thickness (nm): ');

% Calculation
% gap
gap_mm = GAP_UM * MICRO_TO_MILLI;
% cross-sectional area
bigLength_um = NUM_OF_FINGERS * (2*FINGER_LENGTH_UM + 2*3*GAP_UM);
bigLength_mm = bigLength_um * MICRO_TO_MILLI;
metal_mm = metal_nm * NANO_TO_MILLI;
crossArea_mm2 = bigLength_mm * metal_mm;
% surface area
fingerArea_um2 = FINGER_LENGTH_UM * GAP_UM;
fingerArea_mm2 = fingerArea_um2 * MICRO_TO_MILLI^2;
fingerAreaTotal_mm2 = NUM_OF_FINGERS * fingerArea_mm2;
topArea_um2 = (FINGER_LENGTH_UM + WIDTH_SIDE_UM) * WIDTH_TOP_UM;
topArea_mm2 = topArea_um2 * MICRO_TO_MILLI^2;
sideArea_um2 = (WIDTH_SIDE_UM * (3*GAP_UM)) * NUM_OF_FINGERS;
sideArea_mm2 = sideArea_um2 * MICRO_TO_MILLI^2;
surfaceArea_mm2 = fingerAreaTotal_mm2 + topArea_mm2 + sideArea_mm2;

%% Statistics
dist_matrix = cell(1,numOfThickness);
dist_matrix_fix = cell(1,numOfThickness);
res_matrix_fix = cell(1,numOfThickness);
resStat_matrix = cell(1,numOfThickness);
resStat_matrix_failed = cell(1,numOfThickness);
resStat_matrix_outlier = cell(1,numOfThickness);
resStat_matrix_fix = cell(1,numOfThickness);
resMean_arr = zeros(1,numOfThickness);
for thicknessNum = 1:numOfThickness
    if numOfThickness > 1
        slope_arr = slope_cell{thicknessNum};
        intercept_arr = intercept_cell{thicknessNum};
        reg_arr = reg_cell{thicknessNum};
        res_arr = res_cell{thicknessNum};
        sampleSize = sampleSize_arr(thicknessNum);
    end
    stats = [slope_arr;intercept_arr;reg_arr;res_arr];
    samples = 1:sampleSize;

    % Normality test
%     [isResNorm,isResLognorm,isResWeibull] = getDistribution(res_arr,'Data');
    dist_arr = getDistribution2(res_arr);
    stat_arr = getStat(res_arr,dist_arr);
    dist_matrix{numOfThickness} = [dist_arr;stat_arr];
%     logRes_arr = log10(res_arr);
    
    % Descriptive statistics
    if contains(dist_arr,'norm','IgnoreCase',true) && ~contains(dist_arr,'logn','IgnoreCase',true)
        isNorm = true;
        norm_idx = strfind(lower(dist_arr),'norm');
        lognorm_idx = strfind(lower(dist_arr),'logn');
        norm_idx = setdiff(norm_idx,lognorm_idx);
    else
        isNorm = false;
    end
    if contains(dist_arr,'logn','IgnoreCase',true)
        isLognorm = true;
        lognorm_idx = strfind(lower(dist_arr),'logn');
    else
        isLognorm = false;
    end
    % range
    resMin = min(res_arr);
    resMax = max(res_arr);
    % mean
    if isLognorm
        statLognorm = stat_arr{lognorm_idx};
        resMean = statLognorm(1);
        resSTD = statLognorm(2);
    elseif isNorm
        statNorm = stat_arr{norm_idx};
        resMean = statNorm(1);
        resSTD = statNorm(2);
    end
    resMean_ord = floor(log10(resMean));
    resMean_coeff = resMean / (10^resMean_ord);
    % standard deviation
    resSTD_ord = floor(log10(resSTD));
    resSTD_coeff = resSTD / (10^resMean_ord);
    % display
    resStat_matrix{thicknessNum} = {...
        sampleSize,...
        resMin,resMax,...
        resMean,resSTD,...
        resMean_coeff,resMean_ord,...
        resSTD_coeff,resSTD_ord,...
        res_arr};
    fprintf('Sample size: %d.\n',sampleSize);
    fprintf('Sample minimum: %g Ohm.\n',resMin);
    fprintf('Sample maximum: %g Ohm.\n',resMax);
    fprintf('Sample mean: %g Ohm.\n',resMean);
    fprintf('Sample standard deviation: %g Ohm.\n',resSTD);
    fprintf('\n');

    % Failed
    fprintf('Detecting failed (<%sOhm)...',fail_char);
    failed_idx = find(res_arr < FAIL_THRESH);
    res_arr_failed = res_arr(failed_idx);
    samples_failed = samples(failed_idx);
    numOfFailed = length(failed_idx);
    resStat_matrix_failed{thicknessNum} = {failed_idx,samples_failed,res_arr_failed,numOfFailed};
    fprintf('%d.\n',numOfFailed);

    % Outlier
    % normal
    % fprintf('Detecting normal outliers...');
    linResOutlier_idx = isoutlier(res_arr,'quartiles');
    numOfLinOutliers = nnz(linResOutlier_idx);
    % fprintf('%d.\n',numOfLinOutliers);
    % log
    fprintf('Detecting logarithmic outliers...');
    logRes_arr = log10(res_arr);
    logRhoOutlier_idx = isoutlier(logRes_arr,'median');
    numOfLogOutliers = nnz(logRhoOutlier_idx);
    fprintf('%d.\n',numOfLogOutliers);
    % total
    % resOutlier_idx = or(linRhoOutlier_idx,logRhoOutlier_idx);
    resOutlier_idx = logRhoOutlier_idx;
    res_arr_outlier = res_arr(resOutlier_idx);
    samples_outlier = samples(resOutlier_idx);
    numOfOutliers = nnz(resOutlier_idx);
    resStat_matrix_outlier{thicknessNum} = {resOutlier_idx,samples_outlier,res_arr_outlier,numOfOutliers};

    % Exclusion
    fprintf('Total excluded data points: ');
    resOutlier_idx = find(resOutlier_idx);
    resExclude_idx = unique([resOutlier_idx,failed_idx]);
    numOfExclude = length(resExclude_idx);
    res_arr_fix = res_arr;
    res_arr_fix(resExclude_idx) = [];
    sampleSize_fix = sampleSize - numOfExclude;
    samples_fix = samples;
    samples_fix(resExclude_idx) = [];
    fprintf('%d.\n',numOfExclude);
    res_matrix_fix{thicknessNum} = {samples_fix,res_arr_fix,sampleSize_fix};
    fprintf('\n');

    % Fixed normality
    dist_arr_fix = getDistribution2(res_arr_fix);
    stat_arr_fix = getStat(res_arr_fix,dist_arr_fix);
%     [isRhoNorm_fix,isRhoLognorm_fix,isRhoWeibull_fix] = getDistribution(res_arr_fix,'Fixed data');
%     rho_dist_arr = getDistribution(rho_arr_fix);
%     dist_cell_fix_alloc = [dist_cell_fix;rho_dist_arr];
%     dist_cell_fix = dist_cell_fix_alloc;
%     dist_matrix_fix{thicknessNum} = {isRhoNorm_fix,isRhoLognorm_fix,isRhoWeibull_fix};

    % Fixed descriptive statistics
    if contains(dist_arr_fix,'norm','IgnoreCase',true)
        isNorm = true;
        norm_idx = strfind(lower(dist_arr_fix),'norm');
    else
        isNorm = false;
    end
    if contains(dist_arr_fix,'logn','IgnoreCase',true)
        isLognorm = true;
        lognorm_idx = strfind(lower(dist_arr_fix),'logn');
    else
        isLognorm = false;
    end
    % range
    resMin_fix = min(res_arr_fix);
    resMax_fix = max(res_arr_fix);
    resLowQuantile_fix = quantile(res_arr_fix,0.25);
    resHighQuantile_fix = quantile(res_arr_fix,0.75);
    % median
    resMed_fix = median(res_arr_fix);
    if isLognorm
        statLognorm = stat_arr{lognorm_idx};
        resMean_fix = statLognorm(1);
        resSTD_fix = statLognorm(2);
    elseif isNorm
        statNorm = stat_arr{norm_idx};
        resMean_fix = statNorm(1);
        resSTD_fix = statNorm(2);
    end
    % mean
    resMean_fix_ord = floor(log10(resMean_fix));
    resMean_fix_coeff = resMean_fix / (10^resMean_fix_ord);
    % standard deviation
    resSTD_fix_ord = floor(log10(resSTD_fix));
    resSTD_fix_coeff = resSTD_fix / (10^resSTD_fix_ord);
    % display
    resMean_arr(thicknessNum) = resMean_fix;
    resStat_matrix_fix{thicknessNum} = {...
        resMin_fix,resMax_fix,...
        resLowQuantile_fix,resHighQuantile_fix,...
        resMed_fix,...
        resMean_fix,resSTD_fix,...
        resMean_fix_coeff,resMean_fix_ord,...
        resSTD_fix_coeff,resSTD_fix_ord,...
        res_arr_fix};
    fprintf('Fixed sample size: %d.\n',sampleSize_fix);
    fprintf('Fixed sample minimum: %g Ohm.\n',resMin_fix);
    fprintf('Fixed sample maximum: %g Ohm.\n',resMax_fix);
    fprintf('Fixed sample mean: %g Ohm.\n',resMean_fix);
    fprintf('Fixed sample standard deviation: %g Ohm.\n',resSTD_fix);
    fprintf('\n');
end

%% Scatter Plot
for thicknessNum = 1:numOfThickness
    if numOfThickness > 1
        sampleSize = sampleSize_arr(thicknessNum);
        samples_fix = res_matrix_fix{thicknessNum}{1};
        res_arr_fix = res_matrix_fix{thicknessNum}{2};
        
        resMean_coeff = resStat_matrix{thicknessNum}{6};
        resMean_ord = resStat_matrix{thicknessNum}{7};
        resSTD_coeff = resStat_matrix{thicknessNum}{8};
        resSTD_ord = resStat_matrix{thicknessNum}{9};
        
        samples_outlier = resStat_matrix_outlier{thicknessNum}{2};
        res_arr_outlier = resStat_matrix_outlier{thicknessNum}{3};
        samples_failed = resStat_matrix_failed{thicknessNum}{2};
        res_arr_failed = resStat_matrix_failed{thicknessNum}{3};
    end
    data_array = [res_arr_fix,res_arr_outlier,res_arr_failed];
    data_bad = [res_arr_outlier,res_arr_failed];
    
    dep_thick_um = depThick_arr_um(thicknessNum);
    scatterTitle = sprintf('Thickness: %.1f \\mum ({\\itn} = %d)',dep_thick_um,sampleSize);
    % scatterSubtitle = sprintf('{\\bf\\itR} = %.4g \\pm %.4g {\\bf\\Omega\\cdotcm}',resMean,resSTD);
    scatterSubtitle = sprintf(...
        '{\\bf\\itR} = %.4g\\times10^{%g} \\pm %.4g\\times10^{%g} {\\bf\\Omega}',...
        resMean_coeff,resMean_ord,resSTD_coeff,resSTD_ord);

    % Linear
    fprintf('Generating scatter plot...');
    scatterName = sprintf('Scatter Plot: %.1f um',dep_thick_um);
    scatterFig = figure('Name',scatterName);
    fig = gcf;
    figNum = get(gcf,'Number');
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
    set(gca,'XColor','k','YColor','k');
    set(gca,'XTick',[]);
    hold on;
    move = (figNum - 1) * FIG_SHIFT;
    figPosX_new = FIG_POS_X + move;
    figPosY_new = figPosY - move;
    set(scatterFig,'Position',[figPosX_new,figPosY_new,FIG_WIDTH,FIG_HEIGHT]);
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
    drawnow;
    fprintf('OK.\n');

    % Export
    if saveFig == true
        thickness_char = sprintf('%.1fum',dep_thick_um);
        scatterFile = sprintf('%s_%s_Scatter_Res',name,thickness_char);
        exportImage(scatterFig,scatterFile,folder);
    end
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
    drawnow;
    if saveFig == true
        logScatterFile = sprintf('%s_%s_Scatter_LogRes',name,thickness_char);
        exportImage(scatterFig,logScatterFile,folder);
    end
    fprintf('\n');
end
numOfScatter = figNum;

%% Box Plot
compiledFigNum = numOfScatter + numOfThickness + 1;
lastStep = numOfThickness + 1;
xData_array = [];
yData_array = [];
for thicknessNum = 1:lastStep
    if numOfThickness > 1
        if thicknessNum ~= lastStep
            res_arr_fix = res_matrix_fix{thicknessNum}{2};
            dep_thick_um = depThick_arr_um(thicknessNum);
            data_len = length(res_arr_fix);
            xVal = dep_thick_um * ones(1,data_len);
            xData_array_alloc = [xData_array,xVal];
            xData_array = xData_array_alloc;
            yData_array_alloc = [yData_array,res_arr_fix];
            yData_array = yData_array_alloc;
            sampleSize_fix = res_matrix_fix{thicknessNum}{3};
            resMean_fix_coeff = resStat_matrix_fix{thicknessNum}{8};
            resMean_fix_ord = resStat_matrix_fix{thicknessNum}{9};
            resSTD_fix_coeff = resStat_matrix_fix{thicknessNum}{10};
            resSTD_fix_ord = resStat_matrix_fix{thicknessNum}{11};
            
%             yData_array_ord = floor(log10(yData_array));
%             yData_array_ord_max = max(yData_array_ord);
%             yData_array_coeff = yData_array / yData_array_ord_max;
% 
%             if yData_array_ord_max >= 12
%                 resOrd = 'T';
%             elseif yData_array_ord_max >= 9
%                 resOrd = 'G';
%             elseif yData_array_ord_max >= 6
%                 resOrd = 'M';
%             elseif yData_array_ord_max >= 3
%                 resOrd = 'k';
%             else
%                 resOrd = '';
%             end
        end
    end
    
    fprintf('Generating box plot...');
    boxWidth = 0.25;
    boxColor = 'k';
    lineColor = 'k';
    boxAlpha = 0;
    lineWidth = 1.5;
    markerStyle = '+';
    markerSize = 10;
    markerColor = 'k';
    
    if thicknessNum ~= lastStep
        boxName = sprintf('Box Plot: %.1f um',dep_thick_um);
        boxFig = figure('Name',boxName);
        boxTitle = sprintf('Thickness: %.1f \\mum ({\\itn} = %d)',dep_thick_um,sampleSize_fix);
        % boxSubtitle = sprintf('{\\bf\\itR} = %.4g \\pm %.4g {\\bf\\Omega\\cdotcm}',resMean_fix,resSTD_fix);
        boxSubtitle = sprintf(...
            '{\\bf\\itR} = %.4g\\times10^{%g} \\pm %.4g\\times10^{%g} {\\bf\\Omega}',...
            resMean_fix_coeff,resMean_fix_ord,resSTD_fix_coeff,resSTD_fix_ord);
    
        boxChart = boxchart(res_arr_fix,...
            'BoxWidth',boxWidth,...
            'BoxFaceColor',boxColor,...
            'WhiskerLineColor',lineColor,...
            'BoxFaceAlpha',boxAlpha,...
            'LineWidth',lineWidth,...
            'MarkerStyle',markerStyle,...
            'MarkerSize',markerSize,...
            'MarkerColor',markerColor);
    else
        boxCompiled_name = 'Box Plot Compiled';
        figBox_all = figure('Name',boxCompiled_name);
        boxTitle = sprintf('Resistance');
        boxSubtitle = '';
        
        boxChart = boxchart(xData_array,yData_array,...
            'BoxWidth',boxWidth,...
            'BoxFaceColor',boxColor,...
            'WhiskerLineColor',lineColor,...
            'BoxFaceAlpha',boxAlpha,...
            'LineWidth',lineWidth,...
            'MarkerStyle',markerStyle,...
            'MarkerSize',markerSize,...
            'MarkerColor',markerColor);
        xlabel('Thickness ({\rm\mu}m)');
    end
    fig = gcf;
    figNum = get(fig,'Number');
    box on;
    ylim('tickaligned');
    set(gca,'XColor','k','YColor','k');
    set(gca,'XTick',[]);
    hold on;
    move = (figNum - 1) * FIG_SHIFT;
    figPosX_new = FIG_POS_X + move;
    figPosY_new = figPosY - move;
    set(fig,'Position',[figPosX_new,figPosY_new,FIG_WIDTH,FIG_HEIGHT]);
    title(boxTitle);
    subtitle(boxSubtitle);
%     if thicknessNum ~= lastStep
        ylabel_char = sprintf('Resistance (\\Omega)');
%     else
%         ylabel_char = sprintf('Resistance (%s\\Omega)',resOrd);
%     end
    ylabel(ylabel_char);
    set(gca,'FontSize',FONT_SIZE);
    if thicknessNum == lastStep
        set(gca,'XTick',depThick_arr_um);
    end
    drawnow;
    fprintf('OK.\n');
    
    % Export
    if saveFig == true
        if thicknessNum ~= lastStep
            thickness_char = sprintf('%.1fum',dep_thick_um);
            boxFile = sprintf('%s_%s_BoxPlot_Res_annot',name,thickness_char);
            exportImage(boxFig,boxFile,folder);
        else
            boxFile = sprintf('%s_ALL_BoxPlot_Res_annot',name);
            exportImage(figBox_all,boxFile,folder);
        end
    end

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
    drawnow;
    if saveFig == true
        if thicknessNum ~= lastStep
            boxFile = sprintf('%s_%s_BoxPlot_LogRes_annot',name,thickness_char);
            exportImage(boxFig,boxFile,folder);
        else
            boxFile = sprintf('%s_ALL_BoxPlot_LogRes_annot',name);
            exportImage(figBox_all,boxFile,folder);
        end
    end
    
    % Export
    title('');
    subtitle('');
    drawnow;
    if saveFig == true
        if thicknessNum ~= lastStep
            boxFile = sprintf('%s_%s_BoxPlot_LogRes',name,thickness_char);
            exportImage(boxFig,boxFile,folder);
        else
            boxFile = sprintf('%s_ALL_BoxPlot_LogRes',name);
            exportImage(figBox_all,boxFile,folder);
        end
    end

    % Export
    set(gca,'YScale','linear');
    ylim('tickaligned');
    drawnow;
    if saveFig == true
        if thicknessNum ~= lastStep
            boxFile = sprintf('%s_%s_BoxPlot_Res',name,thickness_char);
            exportImage(boxFig,boxFile,folder);
        else
            boxFile = sprintf('%s_ALL_BoxPlot_Res',name);
            exportImage(figBox_all,boxFile,folder);
        end
    end
end
numOfBox = figNum - numOfScatter;

%% Statistics
if numOfThickness == 2
    R1 = resStat_matrix_fix{1}{12};
    logR1 = log(R1);
%     [n1,np1] = kstest(R1);
%     if n1 == 1
%         [logn1,logp1] = kstest(logR1);
%     end

    R2 = resStat_matrix_fix{2}{12};
    logR2 = log(R2);
%     [n2,np2] = kstest(R2);
%     if n2 == 1
%         [logn2,logp2] = kstest(logR2);
%     end
    
    isNorm = all(dist_cell_fix(:,1));
    isLognorm = all(dist_cell_fix(:,2));
    isNonNorm = ~isNorm && ~isLognorm;
    if isNorm
        [isVarUnequal,pVar] = vartest2(R1,R2);
        if ~isVarUnequal
            fprintf('The two thicknesses have equal variance\n');
            [hT,pT] = ttest2(R1,R2,'Vartype','equal');
        else
            fprintf('The two thicknesses have UNEQUAL variance\n');
            [hT,pT] = ttest2(R1,R2,'Vartype','unequal');
        end
        fprintf('\tp = %f\n',pVar);
    elseif isLognorm
        [isVarUnequal,pVar] = vartest2(logR1,logR2);
        if ~isVarUnequal
            fprintf('The two thicknesses have equal variance\n');
            [hT,pT] = ttest2(logR1,logR2,'Vartype','equal');
        else
            fprintf('The two thicknesses have UNEQUAL variance\n');
            [hT,pT] = ttest2(logR1,logR2,'Vartype','unequal');
        end
        fprintf('\tp = %f\n',pVar);
    elseif isNonNorm
        [hT,pT] = ranksum(R1,R2);
    end
    
    sig = '';
    if hT == 1
        fprintf('The two thicknesses are statistically significant.\n');
    else
        fprintf('The two thicknesses are NOT statistically significant.\n');
    end
    
    fprintf('\tp = %f\n',pT);
    fprintf('\n');
end

%% Resistivity
% Variables
dep_thick_mm = xData_array * MICRO_TO_MILLI;
x = dep_thick_mm * MILLI_TO_CENTI;
y = yData_array;
depThick_arr_cm = depThick_arr_um * MICRO_TO_MILLI * MILLI_TO_CENTI;
x_avg = depThick_arr_um * MICRO_TO_MILLI * MILLI_TO_CENTI;
y_avg = resMean_arr;
x_char = getVarName(x);
y_char = getVarName(y);

% Dimensions
gap_cm = gap_mm * MILLI_TO_CENTI;
crossArea_cm2 = crossArea_mm2 * MILLI_TO_CENTI^2;
metal_cm = metal_mm * MILLI_TO_CENTI;
surfaceArea_cm2 = surfaceArea_mm2 * MILLI_TO_CENTI^2;

% Equation
R_bulk_eqn = sprintf('(rho * %g / %g)',gap_cm,crossArea_cm2);
% R_leak = sprintf('(rho * (x - %g) / %g)',metal_cm,surfaceArea_cm2);   % with tickness change with metal
R_film_eqn = sprintf('(rho * x / %g)',surfaceArea_cm2);	% no thickness change with metal
R_out_eqn = sprintf('(R_env + 2 * %s)',R_film_eqn);
R_meas_eqn = sprintf('1 / (1 / %s + 1 / %s)',R_bulk_eqn,R_out_eqn);

% Assumptions
R_env_min = 1e12;  % R_env >= 1 TOhm
rho_min = 1e12;     % rho >= 1e12 Ohm*cm

% Fitting
[xData,yData] = prepareCurveData(x,y);
fitData = fittype(R_meas_eqn,'independent',x_char,'dependent',y_char);
opts = fitoptions('Method','NonlinearLeastSquares');
opts.Algorithm = 'Levenberg-Marquardt';
opts.Display = 'Off';
opts.Robust = 'Bisquare';
opts.StartPoint = [R_env_min rho_min];
[fitResult,fitGood] = fit(xData,yData,fitData,opts);

% Evaluation
coeff = coeffvalues(fitResult);
confidenceInterval = confint(fitResult);
% R_env
R_env = coeff(1);
R_env_ord = floor(log10(R_env));
R_env_pow = 10^R_env_ord;
R_env_coeff = R_env / R_env_pow;
R_env_ci = confidenceInterval(:,1);
R_env_ci_lower = R_env_ci(1);
R_env_ci_upper = R_env_ci(2);
R_env_ci_lower_coeff = R_env_ci_lower / R_env_pow;
R_env_ci_upper_coeff = R_env_ci_upper / R_env_pow;
% rho
rho = coeff(2);
rho_ord = floor(log10(rho));
rho_pow = 10^rho_ord;
rho_coeff = rho / rho_pow;
rho_ci = confidenceInterval(:,2);
rho_ci_lower = rho_ci(1);
rho_ci_upper = rho_ci(2);
rho_ci_lower_coeff = rho_ci_lower / rho_pow;
rho_ci_upper_coeff = rho_ci_upper / rho_pow;
% regression
rSquare = fitGood.rsquare;
% values
R_bulk = rho * gap_cm / crossArea_cm2;
R_film = rho * depThick_arr_cm / surfaceArea_cm2;
R_out = R_env + 2 * R_film;
R_meas = 1 ./ (1 / R_bulk + 1 ./ R_out);

% Plot
fitFig = figure('Name','Fitting');
figNum = get(fitFig,'Number');
try
    plot(fitResult,x,y,'predobs');
catch
    plot(fitResult,x,y);
end
hold on;
scatter(x_avg,y_avg);
box on;
title('Fitting');
xlabel('Thickness (cm)');
ylabel('Resistance (\Omega)');
xMax = max(x) + 1e-4;
xlim([0 xMax]);
yBounds = ylim;
yMin = yBounds(1);
yMax = yBounds(2);
% ylim([0 yMax]);
leg = findobj(fitFig,'Type','Legend');
leg.Location = 'best';
leg.String = {'Data','Fit','Bounds','Mean'};
move = (figNum - numOfScatter - numOfBox - 1) * FIG_SHIFT;
figPosX_new = FIG_POS_X + move + 2*FIG_SHIFT;
figPosY_new = figPosY - move;
set(fitFig,'Position',[figPosX_new,figPosY_new,FIG_WIDTH,FIG_HEIGHT]);
set(gca,'FontSize',FONT_SIZE);

R_env_char = sprintf(...
    '{\\bf{\\itR}_{env}} = %.3g\\times10^{%g} \\Omega',...
    R_env_coeff,R_env_ord);
R_env_ci_char = sprintf(...
    '{\\bf{\\itC}_{I}} = (%.3g,%.3g)\\times10^{%g} \\Omega',...
    R_env_ci_lower_coeff,R_env_ci_upper_coeff,R_env_ord);
rho_char = sprintf(...
    '{\\bf\\rho} = %.3g\\times10^{%g} \\Omega\\cdotcm',...
    rho_coeff,rho_ord);
rho_ci_char = sprintf(...
    '{\\bf{\\itC}_{I}} = (%.3g,%.3g)\\times10^{%g} \\Omega\\cdotcm',...
    rho_ci_lower_coeff,rho_ci_upper_coeff,rho_ord);
rSquare_char = sprintf('{\\bf{\\itr}^{2}} = %.3g',rSquare);

annot_text = sprintf('%s\n%s\n%s\n%s\n%s',...
    R_env_char,...
    R_env_ci_char,...
    rho_char,...
    rho_ci_char,...
    rSquare_char);
annot = annotation(...
    fitFig,...
    'textbox',ANNOT_DIM,...
    'String',annot_text,...
    'FontSize',12,...
    'FitBoxToText','on');

% Export
if saveFig == true
    fitFile = sprintf('%s_Fit_Res_annot',name);
    exportImage(fitFig,fitFile,folder);
    fprintf('\n');
    
    delete(annot);
    title('');
    fitFile = sprintf('%s_Fit_Res',name);
    exportImage(fitFig,fitFile,folder);
end
fprintf('\n');

%% Program End
fprintf('PROGRAM ENDED.\n\n');

%% findFunctions
function [] = findFunctions()
true = 1;
functionFolder = 'Analysis_Functions';                      % function folder name
functions_location_Cdrive = 'C:\Analysis_Functions';        % function folder in :C
folderExists = 7;                                           % folder existing value
fprintf('Searching for Function Folder in directory...');   % searching for SDK
if exist(functionFolder,'dir') == folderExists          % functions found in directory
    fprintf('OK.\n\n');                                 % functions found
    path(path,functionFolder);                          % adding functions to path (just in case)
else                                                            % functions not found
    prompt = 'FUNCTIONS NOT FOUND IN DIRECTORY';             	% message prompt
    waitfor(msgbox(prompt,titleError));                         % functions not found in directory
    fprint('NOT FOUND.\n');
    fprintf('Searching for Funtion Folder in :C...') ;          % searching for Funtion Folder in C:
    if exist(functions_location_Cdrive,'dir') == folderExists 	% functions found
        fprintf('OK.\n\n');                                     % functions found in C:
        path(path,functions_location_Cdrive);                	% adding Ffunctions to directory
    else                                                      	% functions not found
        fprintf('NOT FOUND.\n');                                % functions not found in C:
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
            fprintf('\nFuntions located.\n\n'); % path located
            path(path,functions_location);    	% adding Funtion Folder to directory
        end
    end
end

end