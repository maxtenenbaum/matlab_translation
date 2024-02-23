function [File,isQuit] = runStatistics(File,saveFig)
close all;
%% Constants
% Values
FAIL_THRESH = 100e9;
TERA = 1e12;
GIGA = 1e9;
MEGA = 1e6;

% Plot
FONT_SIZE = 20;

% Figure
FIG_WIDTH = 960;
FIG_HEIGHT = 720;
WINDOW_HEADER = 80;
FIG_SHIFT = 20;

%% Variables
% Initialization
isQuit = false;
name = File.Name;
folder = File.Path;
numOfSamples = length(File.Data);
slope_arr = zeros(numOfSamples,1);
intercept_arr = zeros(numOfSamples,1);
r2_arr = zeros(numOfSamples,1);
resistance_arr = zeros(numOfSamples,1);
samples_arr = 1:numOfSamples;

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

% Structure
Stat = struct( ...
    'Mean',[], ...
    'SD',[]);
Statistics = struct( ...
    'Arithmetic',Stat, ...
    'Geometric',Stat, ...
    'Min',[], ...
    'Max',[], ...
    'Median',[], ...
    'Outliers',[], ...
    'IsNormal',[], ...
    'IsLognormal',[]);
File.Statistics = Statistics;

% Screen
[screenX,~,~,screenHeight,numOfMonitors] = getScreenSize2();
figPosX = screenX(numOfMonitors);
screenHeight_use = screenHeight(numOfMonitors);
figPosY = screenHeight_use - FIG_HEIGHT - WINDOW_HEADER;

%% Arrays
for sampleNum = samples_arr
    resistance_arr(sampleNum) = File.Data(sampleNum).Resistance.Value ;
    slope_arr(sampleNum) = File.Data(sampleNum).Resistance.Slope;
    intercept_arr(sampleNum) = File.Data(sampleNum).Resistance.Intercept;
    r2_arr(sampleNum) = File.Data(sampleNum).Resistance.R2;
end

%% Statistics
% Normality test
[~,~,~] = getDistribution(resistance_arr,'Data');
logRes_arr = log10(resistance_arr);

% Descriptive statistics
% range
resistance_min = min(resistance_arr);
resistance_max = max(resistance_arr);
% mean
resistance_mean = mean(resistance_arr);
resistance_mean_ord = floor(log10(resistance_mean));
resistance_mean_coeff = resistance_mean / (10^resistance_mean_ord);
resistance_sd = std(resistance_arr);
% standard deviation
resistance_sd_ord = floor(log10(resistance_sd));
resistance_sd_coeff = resistance_sd / (10^resistance_mean_ord);
% display
fprintf('Sample size: %d\n',numOfSamples);
fprintf('Sample minimum: %g Ohm\n',resistance_min);
fprintf('Sample maximum: %g Ohm\n',resistance_max);
fprintf('Sample mean: %g Ohm\n',resistance_mean);
fprintf('Sample standard deviation: %g Ohm\n',resistance_sd);
fprintf('\n');

% Failed
fprintf('Detecting failed (<%sOhm)...',fail_char);
failed_idx = find(resistance_arr < FAIL_THRESH);
res_arr_failed = resistance_arr(failed_idx);
samples_failed = samples_arr(failed_idx);
numOfFailed = length(failed_idx);
fprintf('%d\n',numOfFailed);

% Outlier
% normal
% fprintf('Detecting normal outliers...');
% linResOutlier_tf = isoutlier(resistance_arr,'quartiles');
% numOfLinOutliers = nnz(linResOutlier_tf);
% fprintf('%d\n',numOfLinOutliers);
linResOutlier_tf = zeros(numOfSamples,1);
% log
fprintf('Detecting logarithmic outliers...');
logResOutlier_tf = isoutlier(logRes_arr,'median');
numOfLogOutliers = nnz(logResOutlier_tf);
fprintf('%d\n',numOfLogOutliers);

% Exclusion
fprintf('Total exluded data points: ');
outlier_tf = linResOutlier_tf | logResOutlier_tf;
outlier_idx = find(outlier_tf);
outlier_arr = resistance_arr(outlier_tf);
numOfOutliers = length(outlier_idx);
resistance_arr_fix = resistance_arr;
resistance_arr_fix(outlier_tf) = [];
numOfSamples_fix = numOfSamples - numOfOutliers;
samples_arr_fix = samples_arr;
samples_arr_fix(outlier_tf) = [];
File.Statistics.Outliers = outlier_arr;
fprintf('%d\n',numOfOutliers);
fprintf('\n');

% Fixed normality
[isResNorm_fix,isResLognorm_fix,~] = getDistribution(resistance_arr_fix,'Fixed data');
File.Statistics.IsNormal = isResNorm_fix;
File.Statistics.IsLognormal = isResLognorm_fix;

% Fixed descriptive statistics
% median
resistance_median_fix = median(resistance_arr_fix);
% range
resistance_min_fix = min(resistance_arr_fix);
resistance_max_fix = max(resistance_arr_fix);
% mean
resistance_mean_fix = mean(resistance_arr_fix);
resistance_mean_fix_ord = floor(log10(resistance_mean_fix));
resistance_mean_fix_coeff = resistance_mean_fix / (10^resistance_mean_fix_ord);
resistance_geomean_fix = geomean(resistance_arr_fix);
% standard deviation
resistance_sd_fix = std(resistance_arr_fix);
resistance_sd_fix_ord = floor(log10(resistance_sd_fix));
resistance_sd_fix_coeff = resistance_sd_fix / (10^resistance_sd_fix_ord);
resistance_gsd_fix = geostd(resistance_arr_fix);
% store
File.Statistics.Arithmetic.Mean = resistance_mean_fix;
File.Statistics.Arithmetic.SD = resistance_sd_fix;
File.Statistics.Geometric.Mean = resistance_geomean_fix;
File.Statistics.Geometric.SD = resistance_gsd_fix;
File.Statistics.Min = resistance_min_fix;
File.Statistics.Max = resistance_max_fix;
File.Statistics.Median = resistance_median_fix;
File.Statistics.IsNormal = isResNorm_fix;
File.Statistics.IsLognormal = isResLognorm_fix;
% display
fprintf('Fixed sample size: %d\n',numOfSamples_fix);
fprintf('Fixed sample minimum: %g Ohm\n',resistance_min_fix);
fprintf('Fixed sample maximum: %g Ohm\n',resistance_max_fix);
fprintf('Fixed sample arithmetic mean: %g Ohm\n',resistance_mean_fix);
fprintf('Fixed sample geometric mean: %g Ohm\n',resistance_geomean_fix);
fprintf('Fixed sample standard deviation: %g Ohm\n',resistance_sd_fix);
fprintf('\n');

%% Scatter Plot
data_array = [resistance_arr_fix;outlier_arr;res_arr_failed];
data_bad = [outlier_arr;res_arr_failed];
scatterTitle = sprintf('Resistance ({\\itn} = %d)',numOfSamples);
scatterSubtitle = sprintf(...
    '{\\bf\\itR} = %.4g\\times10^{%g} \\pm %.4g\\times10^{%g} {\\bf\\Omega}',...
    resistance_mean_coeff,resistance_mean_ord,resistance_sd_coeff,resistance_sd_ord);

% Linear
fprintf('Generating scatter plot...');
scatterFig = figure('Name','Scatter Plot');
plot(samples_arr_fix,resistance_arr_fix,...
    'LineStyle','none',...
    'Marker','o',...
    'MarkerFaceColor','k',...
    'MarkerSize',5,...
    'Color','k');
hold on;
plot(outlier_idx,outlier_arr,...
    'LineStyle','none',...
    'Marker','+',...
    'MarkerSize',10,...
    'Color','b');
plot(samples_failed,res_arr_failed,...
    'LineStyle','none',...
    'Marker','x',...
    'MarkerSize',10,...
    'Color','r');
box on;
ylim('tickaligned');
xlim('padded');
set(gca,'xtick',[]);
hold on;
set(scatterFig,'Position',[figPosX,figPosY,FIG_WIDTH,FIG_HEIGHT]);
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
if saveFig
    scatterFilename = sprintf('%s_Scatter_Res.tif',name);
    scatterFilepath = fullfile(folder,scatterFilename);
    exportPlot(scatterFig,scatterFilepath,600);
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
if saveFig
    logScatterFilename = sprintf('%s_Scatter_LogRes.tif',name);
    logScatterFilepath = fullfile(folder,logScatterFilename);
    exportPlot(scatterFig,logScatterFilepath,600);
end
fprintf('\n');


%% Box Plot
fprintf('Generating box plot...');
boxTitle = sprintf('Resistance ({\\itn} = %d)',numOfSamples_fix);
boxSubtitle = sprintf(...
    '{\\bf\\itR} = %.4g\\times10^{%g} \\pm %.4g\\times10^{%g} {\\bf\\Omega}',...
    resistance_mean_fix_coeff,resistance_mean_fix_ord,resistance_sd_fix_coeff,resistance_sd_fix_ord);
boxWidth = 0.25;
boxColor = 'k';
lineColor = 'k';
boxAlpha = 0;
lineWidth = 1.5;
markerStyle = '+';
markerSize = 10;
markerColor = 'k';

boxFig = figure('Name','Box Plot');
boxchart(resistance_arr_fix,...
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
figPosX_new = figPosX + FIG_SHIFT;
figPosY_new = figPosY - FIG_SHIFT;
set(boxFig,'Position',[figPosX_new,figPosY_new,FIG_WIDTH,FIG_HEIGHT]);
title(boxTitle);
subtitle(boxSubtitle);
ylabel('Resistance (\Omega)');
set(gca,'FontSize',FONT_SIZE);
fprintf('OK\n');

% Export
if saveFig
    boxFilename = sprintf('%s_BoxPlot_Res_annot.tif',name);
    boxFilepath = fullfile(folder,boxFilename);
    exportPlot(boxFig,boxFilepath,600);
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
if saveFig
    boxFilename = sprintf('%s_BoxPlot_LogRes_annot.tif',name);
    boxFilepath = fullfile(folder,boxFilename);
    exportPlot(boxFig,boxFilepath,600);
end

if saveFig
    % Export
    title('');
    subtitle('');
    boxFilename = sprintf('%s_BoxPlot_LogRes.tif',name);
    boxFilepath = fullfile(folder,boxFilename);
    exportPlot(boxFig,boxFilepath,600);
end

% Export
set(gca,'YScale','linear');
ylim('tickaligned');
if saveFig
    boxFilename = sprintf('%s_BoxPlot_Res.tif',name);
    boxFilepath = fullfile(folder,boxFilename);
    exportPlot(boxFig,boxFilepath,600);
end

end