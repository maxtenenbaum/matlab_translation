function [File,isQuit] = processWeibull(File,getOutliers,getBounds,saveFig)
close all;
%% Constants
% Processing
FONT_SIZE = 20;
CHAR_LIFE = 1 - exp(-1);
VOLTAGE_FAILURE_NAME = 'Voltage Failure';
FAILURE_TIME_NAME = 'Failure Time';
WEIBULL_TITLE = 'Weibull Plot';

% Figure
FIG_WIDTH = 960;
WINDOW_HEADER = 100;
FIG_SHIFT = 20;
% Box
FIG_HEIGHT_BOX = 480;
% Weibull
FIG_HEIGHT_WEIBULL = 720;

% MATLAB
MATLAB_COLOR = {...
    '#0072BD',...   % blue
    '#D95319',...   % orange
    '#EDB120',...   % yellow
    '#7E2F8E',...   % purple
    '#77AC30',...   % green
    '#4DBEEE',...   % cyan
    '#A2142F'};     % maroon

%% Weibull Processing
isQuit = false;
name = File.Name;
folder = File.Path;

% Figure
figNum = 0;
lineStyle = '--';
lineWidth = 1.5;
marker = '.';
markerSize = 20;
boxWidth = 0.25;
boxColor = 'k';
boxAlpha = 0;
markerStyle = '+';
markerColor = 'k';
% Characteristic Life
% charLife_cent = CHAR_LIFE * 100;
% charLife_annot = sprintf('Characteristic Life = %.2f%%',life_cent);
charLife_annot = sprintf('Characteristic Life at %.3f',CHAR_LIFE);

% Screen
[screenX,~,~,screenHeight,numOfMonitors] = getScreenSize2();
figPosX = screenX(numOfMonitors);
screenHeight_use = screenHeight(numOfMonitors);
figPosY = screenHeight_use - WINDOW_HEADER;

timeStep_arr = [File.Data(:).TimeStep];
timeStep_min_arr = timeStep_arr / 60;
ft_xgroupdata = [];
ft_ygroupdata = [];
vf_ygroupdata = [];
vf_xgroupdata = [];

numOfCateg = length(File.Data);
figNumWeibull_last = 3 * numOfCateg + 1;
figNumBoxFT_last = 3 * numOfCateg + 2;
figNumBoxVF_last = 3 * numOfCateg + 3;

prob_min_arr = zeros(numOfCateg,1);
prob_max_arr = zeros(numOfCateg,1);
probPlot_min_arr = zeros(numOfCateg,1);
probPlot_max_arr = zeros(numOfCateg,1);

% Structure
Parameter = struct( ...
    'Value',[], ...
    'CI',[]);
Normal = struct( ...
    'Mean',[], ...
    'SD',[]);
Weibull = struct( ...
    'Mean',[], ...
    'SD',[], ...
    'Scale',Parameter, ...
    'Shape',Parameter);
Distribution = struct( ...
    'Weibull',Weibull,...
    'Normal',Normal, ...
    'Outliers',[]);
Statistics = struct( ...
    'Time',Distribution, ...
    'Voltage',Distribution);
for categNum = 1:numOfCateg
    File.Data(categNum).Statistics = Statistics;
end

boxComplile_arr = zeros(1,2);
for categNum = 1:numOfCateg
    %% Weibull Plot
    color = MATLAB_COLOR{categNum};
    wblColor = hex2rgb(color);

    %% Voltage Failure Weibull
    fprintf('Processing Voltage Failure...\n');
    numOfSamples = length(File.Data(categNum).Sample);
    vf = zeros(numOfSamples,1);
    for sampleNum = 1:numOfSamples
        voltage = File.Data(categNum).Sample(sampleNum).Failure.Voltage;
        vf(sampleNum) = voltage;
    end
    vf = sort(vf);
    if getOutliers
        [vf,outlier_idx] = removeOutliers(vf);
        File.Data(categNum).Statistics.Voltage.Outliers = outlier_idx;
    end
    sampleSize_vf = length(vf);
    [~,~,~] = getDistribution(vf,VOLTAGE_FAILURE_NAME);
    % if ~isVFWeibull
    %     msg = msgbox('Voltage Failure is NOT Weibull distributed.');
    %     waitfor(msg);
    %     isQuit = true;
    %     return;
    % end
    fprintf('\n');

    ord = floor(log10(min(vf)));
    eps = 10^(ord-6);
    vf = makeDataUnique(vf,eps);
    [vf_param,vf_ci] = wblfit(vf);
    vf_a = vf_param(1);
    vf_a_ci = vf_ci(:,1);
    vf_a_ci_lower = vf_a_ci(1);
    vf_a_ci_upper = vf_a_ci(2);
    vf_a_ci = [vf_a_ci_lower vf_a_ci_upper];
    vf_b = vf_param(2);
    vf_b_ci = vf_ci(:,2);
    vf_b_ci_lower = vf_b_ci(1);
    vf_b_ci_upper = vf_b_ci(2);
    vf_b_ci = [vf_b_ci_lower vf_b_ci_upper];
    File.Data(categNum).Statistics.Voltage.Weibull.Scale.Value = vf_a;
    File.Data(categNum).Statistics.Voltage.Weibull.Scale.Confidence = vf_a_ci;
    File.Data(categNum).Statistics.Voltage.Weibull.Shape.Value = vf_b;
    File.Data(categNum).Statistics.Voltage.Weibull.Shape.Confidence = vf_b_ci;

    [vf_mean_weibull,vf_var_weibull] = wblstat(vf_a,vf_b);
    vf_sd_weibull = sqrt(vf_var_weibull);
    File.Data(categNum).Statistics.Voltage.Weibull.Mean = vf_mean_weibull;
    File.Data(categNum).Statistics.Voltage.Weibull.SD = vf_sd_weibull;

    vf_mean_norm = mean(vf);
    vf_sd_norm = std(vf);
    File.Data(categNum).Statistics.Voltage.Normal.Mean = vf_mean_norm;
    File.Data(categNum).Statistics.Voltage.Normal.SD = vf_sd_norm;

    %% Failure Time Weibull
    fprintf('Processing Failure Time...\n');
    numOfSamples = length(File.Data(categNum).Sample);
    ft = zeros(numOfSamples,1);
    for sampleNum = 1:numOfSamples
        time = File.Data(categNum).Sample(sampleNum).Failure.Time;
        ft(sampleNum) = time;
    end
    ft = sort(ft);
    timeStep = File.Data(categNum).TimeStep;
    timeStep_min = timeStep / 60;
    figNum = figNum + 1;
    fprintf('Figure %d: Failure Time\n',figNum);
    figNum_arr = [figNum,figNumWeibull_last];
    for figNum_idx = figNum_arr
        fprintf('Figure %d: Failure Time\n',figNum_idx);
        ft_fig = figure(figNum_idx);
        if figNum_idx == figNum
            if getOutliers
                [ft,outlier_idx] = removeOutliers(ft);
                File.Data(categNum).Statistics.Time.Outliers = outlier_idx;
            end
        end
        sampleSize_ft = length(ft);
        [~,isFTLognorm,isFTWeibull] = getDistribution(ft,FAILURE_TIME_NAME);
        if ~(isFTWeibull || isFTLognorm)
            msg = msgbox('Failure Time is NOT Weibull distributed.');
            waitfor(msg);
            isQuit = true;
            return;
        end
        fprintf('\n');

        ord = floor(log10(min(ft)));
        eps = 10^(ord-6);
        ft = makeDataUnique(ft,eps);
        [ft_param,ft_ci] = wblfit(ft);
        scale_a = ft_param(1);
        scale_a_ci = ft_ci(:,1);
        scale_a_ci_lower = scale_a_ci(1);
        scale_a_ci_upper = scale_a_ci(2);
        scale_a_ci = [scale_a_ci_lower scale_a_ci_upper];
        shape_b = ft_param(2);
        shape_b_ci = ft_ci(:,2);
        shape_b_ci_lower = shape_b_ci(1);
        shape_b_ci_upper = shape_b_ci(2);
        shape_b_ci = [shape_b_ci_lower shape_b_ci_upper];
        File.Data(categNum).Scale.Value = scale_a;
        File.Data(categNum).Scale.CI = scale_a_ci;
        File.Data(categNum).Shape.Value = shape_b;
        File.Data(categNum).Shape.CI = shape_b_ci;
        File.Data(categNum).Statistics.Time.Weibull.Scale.Value = scale_a;
        File.Data(categNum).Statistics.Time.Weibull.Scale.Confidence = scale_a_ci;
        File.Data(categNum).Statistics.Time.Weibull.Shape.Value = shape_b;
        File.Data(categNum).Statistics.Time.Weibull.Shape.Confidence = shape_b_ci;

        voltageStep = File.Data(categNum).VoltageStep;
        [numOfSteps,lastVoltageStep] = getNumOfSteps(scale_a,timeStep,voltageStep);
        File.Data(categNum).Voltage = lastVoltageStep;
        File.Data(categNum).NumberOfSteps = numOfSteps;

        [ft_mean_weibull,ft_var_weibull] = wblstat(scale_a,shape_b);
        ft_sd_weibull = sqrt(ft_var_weibull);
        File.Data(categNum).Statistics.Time.Weibull.Mean = ft_mean_weibull;
        File.Data(categNum).Statistics.Time.Weibull.SD = ft_sd_weibull;

        ft_mean_norm = mean(ft);
        ft_sd_norm = std(ft);
        File.Data(categNum).Statistics.Time.Normal.Mean = ft_mean_norm;
        File.Data(categNum).Statistics.Time.Normal.SD = ft_sd_norm;

        % wblplot_line = 'none';
        wblplot_line = '--';
        ft_plot = wblplot(ft);
        lineHandles = findobj(ft_plot);
        dataHandle = lineHandles(1);
        dataHandle.Marker = marker;
        dataHandle.MarkerSize = markerSize;
        dataHandle.MarkerEdgeColor = wblColor;
        dataHandle.HandleVisibility = 'off';
        innerHandle = lineHandles(2);
        innerHandle.Color = 'none';
        innerHandle.LineStyle = 'none';
        innerHandle.Marker = 'none';
        innerHandle.HandleVisibility = 'off';
        lineHandle = lineHandles(3);
        lineHandle.Color = wblColor;
        lineHandle.LineStyle = wblplot_line;
        lineHandle.LineWidth = lineWidth;
        lineHandle.Marker = 'none';
        grid off;
        box on;
        ax = gca;
        set(ax,'XMinorTick','off');
        set(ax,'XMinorTick','on');
        set(ax,'LineWidth',lineWidth);

        % Characteristic Life
        hold on;
        figure(ft_fig);
        yCharLife = getTransform(CHAR_LIFE);
        if figNum_idx ~= figNumWeibull_last
            horzLine = yline(yCharLife,'--',charLife_annot,...
                'LineWidth',lineWidth,...
                'FontSize',FONT_SIZE-2,...
                'LabelHorizontalAlignment','left', ...
                'HandleVisibility','off');
        end

        % Confidence Bounds
        if getBounds
            data = ft;
            param = ft_param;
            if contains2(wblplot_line,'none')
                method = 'beta';
            else
                method = 'hazen';
            end
            prob_arr = getMedianRank(data,method,false);
            probPlot_arr = getTransform(prob_arr);
            [y,lowerBound,upperBound,shadeX,shadeY] ...
                = getConfidenceBounds2(data,param,method);
            % line
            if contains2(wblplot_line,'none')
                plot(data,y, ...
                    'LineStyle',wblplot_line, ...
                    'Color',wblColor, ...
                    'LineWidth',lineWidth);
                % h.HandleVisibility = 'off';
            end
            % bounds
            plot(lowerBound,probPlot_arr, ...
                'LineStyle',':', ...
                'Color',wblColor, ...
                'HandleVisibility','off');
            plot(upperBound,probPlot_arr, ...
                'LineStyle',':', ...
                'Color',wblColor, ...
                'HandleVisibility','off');
            % shade
            fill(shadeX,shadeY,wblColor, ...
                'EdgeColor','none', ...
                'FaceAlpha',0.05, ...
                'HandleVisibility','off');
        end
        xlim('tickaligned');
        drawnow;
        xBounds = xlim;
        timeMin = min(xBounds);
        timeMax = max(xBounds);
        ordMin = floor(log10(timeMin));
        ordMax = ceil(log10(timeMax));
        xMin = 10^ordMin;
        xMax = 10^ordMax;
        xlim([xMin xMax]);
        lower_min = min(prob_arr);
        upper_max = max(prob_arr);
        prob_min_val = 10^floor(log10(lower_min));
        if prob_min_val >= 0.1
            prob_min_val = 0.01;
        end
        prob_max_val = 0.99;
        increment = 0.09;
        while upper_max > prob_max_val
            increment = increment / 10;
            prob_max_val = prob_max_val + increment;
        end
        probLimits = [prob_min_val prob_max_val];
        probPlotLimits = getTransform(probLimits);
        ylim(probPlotLimits);
        prob_min_arr(categNum) = prob_min_val;
        prob_max_arr(categNum) = prob_max_val;
        probPlot_min_arr(categNum) = probPlotLimits(1);
        probPlot_max_arr(categNum) = probPlotLimits(2);

        % Adjust Plot
        move = (figNum_idx - 1) * FIG_SHIFT;
        figPosX_new = figPosX + move;
        figPosY_new = figPosY - move - FIG_HEIGHT_WEIBULL;
        set(ft_fig,'Position',[figPosX_new,figPosY_new,FIG_WIDTH,FIG_HEIGHT_WEIBULL]);
        ft_title = sprintf('%s ({\\itn} = %d)',FAILURE_TIME_NAME,sampleSize_ft);
        vf_title = sprintf('%s ({\\itn} = %d)',VOLTAGE_FAILURE_NAME,sampleSize_vf);
        title(ft_title);
        xlabel('Failure Time (s)');
        ylabel('Probability of Failure');
        set(ax,'FontSize',FONT_SIZE);

        scale_a_round = round(scale_a,1);
        scale_a_comma = addCommas(scale_a_round);
        mean_round = round(ft_mean_weibull,1);
        mean_comma = addCommas(mean_round);
        sd_round = round(ft_sd_weibull,1);
        sd_comma = addCommas(sd_round);
        ftParam = sprintf('{\\ita} = %s s, {\\itb} = %.1f',scale_a_comma,shape_b);
        ftStat = sprintf('{\\itm} = %s \\pm %s s',mean_comma,sd_comma);
        ftSubtitle = sprintf('Failure Time: %s | %s',ftParam,ftStat);

        vfParam = sprintf('{\\ita} = %.2f V, {\\itb} = %.3g',vf_a,vf_b);
        vfStat = sprintf('{\\itm} = %.2f \\pm %.3g V',vf_mean_weibull,vf_sd_weibull);
        vfSubtitle = sprintf('Voltage Failure: %s | %s',vfParam,vfStat);

        weibullSubtitle_raw = sprintf('%s\n%s',ftSubtitle,vfSubtitle);
        weibullSubtitle = erase(weibullSubtitle_raw,'+0');
        if figNum_idx ~= figNumWeibull_last
            subtitle(weibullSubtitle,'FontSize',FONT_SIZE-2);
        end
        

        if figNum_idx > figNum
            hold on;
        end

        % Export
        if saveFig
            if figNum_idx == figNum
                ftFilename = sprintf('%s_%gmin_Weibull_FT_annot.tif',name,timeStep_min);
                ftFilepath = fullfile(folder,ftFilename);
                exportPlot(ft_fig,ftFilepath,600);
                title('');
                subtitle('');
                lineHandle.LineWidth = lineWidth;
                delete(horzLine);
                drawnow;
                ftFilename = sprintf('%s_%gmin_Weibull_FT.tif',name,timeStep_min);
                ftFilepath = fullfile(folder,ftFilename);
                exportPlot(ft_fig,ftFilepath,600);
                fprintf('\n');
            end
        end
    end

    %% Failure Time Box Plot
    figNum = figNum + 1;
    figNum_arr = [figNum,figNumBoxFT_last];
    for figNum_idx = figNum_arr
        fprintf('Figure %d: Failure Time Box Plot\n',figNum_idx);
        ftBox_fig = figure(figNum_idx);
        ax = gca;
        ft_name = ones(1,sampleSize_ft)' * timeStep_min;
        ft_xgroupdata_alloc = [ft_xgroupdata;ft_name];
        ft_xgroupdata = ft_xgroupdata_alloc;
        ft_ygroupdata_alloc = [ft_ygroupdata;ft];
        ft_ygroupdata = ft_ygroupdata_alloc;
        if figNum_idx ~= figNumBoxFT_last
            boxchart(ft,...
                'BoxWidth',boxWidth,...
                'BoxFaceColor',boxColor,...
                'WhiskerLineColor',boxColor,...
                'BoxFaceAlpha',boxAlpha,...
                'LineWidth',lineWidth,...
                'MarkerStyle',markerStyle,...
                'MarkerSize',markerSize,...
                'MarkerColor',markerColor);
            set(ax,'xtick',[]);
        else
            boxComplile_arr(1) = figNum_idx;
            boxchart(ft_xgroupdata,ft_ygroupdata,...
                'BoxWidth',boxWidth,...
                'BoxFaceColor',boxColor,...
                'WhiskerLineColor',boxColor,...
                'BoxFaceAlpha',boxAlpha,...
                'LineWidth',lineWidth,...
                'MarkerStyle',markerStyle,...
                'MarkerSize',markerSize,...
                'MarkerColor',markerColor);
            xlabel('Time Step (min)');
            set(ax,'XTick',timeStep_min_arr);
        end
        set(ax,'LineWidth',lineWidth);
        box on;
        ylim('tickaligned');
        yMax = max(ft_ygroupdata);
        ordMax = floor(log10(yMax));
        if ordMax >= 3
            ax.YAxis.Exponent = ordMax;
            ylim([0 yMax]);
        end

        hold on;
        move = (figNum_idx - 1) * FIG_SHIFT;
        figPosX_new = figPosX + move;
        figPosY_new = figPosY - move - FIG_HEIGHT_BOX;
        set(ftBox_fig,'Position',[figPosX_new,figPosY_new,FIG_WIDTH,FIG_HEIGHT_BOX]);
        title(ft_title);
        ylabel('Failure Time (s)');
        set(gca,'FontSize',FONT_SIZE);
        set(ax,'LineWidth',lineWidth);
        mean_round = round(ft_mean_norm,1);
        mean_comma = addCommas(mean_round);
        sd_round = round(ft_sd_norm,1);
        sd_comma = addCommas(sd_round);
        ftSubtitle = sprintf('Failure Time: {\\itm} = %s \\pm %s s',mean_comma,sd_comma);
        vfSubtitle = sprintf('Voltage Failure: {\\itm} = %.2f \\pm %.2f V',vf_mean_norm,vf_sd_norm);
        boxSubtitle = sprintf('%s\n%s',ftSubtitle,vfSubtitle);
        if figNum_idx ~= figNumBoxFT_last
            subtitle(boxSubtitle,'FontSize',FONT_SIZE-2);
        end
        

        if figNum_idx > figNum
            hold on;
        end

        % Export
        if saveFig
            if figNum_idx == figNum
                boxFilename = sprintf('%s_%gmin_BoxPlot_FT_annot.tif',name,timeStep_min);
                boxFilepath = fullfile(folder,boxFilename);
                exportPlot(ftBox_fig,boxFilepath,600);
                fprintf('\n');
            end
        end

        % Export
        title('');
        subtitle('');
        if saveFig
            if figNum_idx == figNum
                boxFilename = sprintf('%s_%gmin_BoxPlot_FT.tif',name,timeStep_min);
                boxFilepath = fullfile(folder,boxFilename);
                exportPlot(ftBox_fig,boxFilepath,600);
                fprintf('\n');
            end
        end
    end

    %% Voltage Failure Box Plot
    figNum = figNum + 1;
    figNum_arr = [figNum,figNumBoxVF_last];
    for figNum_idx = figNum_arr
        fprintf('Figure %d: Voltage Failure Box Plot\n',figNum_idx);
        vfBox_fig = figure(figNum_idx);
        ax = gca;
        vf_ygroupdata_alloc = [vf_ygroupdata;vf];
        vf_ygroupdata = vf_ygroupdata_alloc;
        vf_name = ones(1,sampleSize_vf)' * timeStep_min;
        vf_xgroupdata_alloc = [vf_xgroupdata;vf_name];
        vf_xgroupdata = vf_xgroupdata_alloc;

        if figNum_idx ~= figNumBoxVF_last
            boxchart(vf,...
                'BoxWidth',boxWidth,...
                'BoxFaceColor',boxColor,...
                'WhiskerLineColor',boxColor,...
                'BoxFaceAlpha',boxAlpha,...
                'LineWidth',lineWidth,...
                'MarkerStyle',markerStyle,...
                'MarkerSize',markerSize,...
                'MarkerColor',markerColor);
            set(ax,'xtick',[]);
        else
            boxComplile_arr(2) = figNumBoxVF_last;
            boxchart(vf_xgroupdata,vf_ygroupdata,...
                'BoxWidth',boxWidth,...
                'BoxFaceColor',boxColor,...
                'WhiskerLineColor',boxColor,...
                'BoxFaceAlpha',boxAlpha,...
                'LineWidth',lineWidth,...
                'MarkerStyle',markerStyle,...
                'MarkerSize',markerSize,...
                'MarkerColor',markerColor);
            xlabel('Time Step (min)');
            set(ax,'XTick',timeStep_min_arr);
        end
        set(ax,'LineWidth',lineWidth);
        box on;
        ylim('tickaligned');
        hold on;
        move = (figNum_idx - 1) * FIG_SHIFT;
        figPosX_new = figPosX + move;
        figPosY_new = figPosY - move - FIG_HEIGHT_BOX;
        set(vfBox_fig,'Position',[figPosX_new,figPosY_new,FIG_WIDTH,FIG_HEIGHT_BOX]);
        title(vf_title);
        ylabel('Voltage Failure (V)');
        set(gca,'FontSize',FONT_SIZE);
        set(ax,'LineWidth',lineWidth);
        vfSubtitle = sprintf('Voltage Failure: {\\itm} = %.1f \\pm %.1f V',vf_mean_norm,vf_sd_norm);
        ftSubtitle = sprintf('Failure Time: {\\itm} = %.1f \\pm %.1f s',ft_mean_norm,ft_sd_norm);
        boxSubtitle = sprintf('%s\n%s',vfSubtitle,ftSubtitle);
        if figNum_idx ~= figNumBoxVF_last
            subtitle(boxSubtitle,'FontSize',FONT_SIZE-2);
        end
        if figNum_idx > figNum
            hold on;
        end
        drawnow;

        % Export
        if saveFig
            if figNum_idx == figNum
                boxFilename = sprintf('%s_%gmin_BoxPlot_VF_annot.tif',name,timeStep_min);
                boxFilepath = fullfile(folder,boxFilename);
                exportPlot(vfBox_fig,boxFilepath,600);
                title('');
                subtitle('');
                boxFilename = sprintf('%s_%gmin_BoxPlot_VF.tif',name,timeStep_min);
                boxFilepath = fullfile(folder,boxFilename);
                exportPlot(vfBox_fig,boxFilepath,600);
                fprintf('\n');
            end
        end
    end
end

% Weibull
fprintf('Figure %d: Weibull Compiled\n',figNumWeibull_last);
figWeibull = figure(figNumWeibull_last);
xlim('tickaligned');
drawnow;
xBounds = xlim;
timeMin = min(xBounds);
timeMax = max(xBounds);
ordMin = floor(log10(timeMin));
ordMax = ceil(log10(timeMax));
xMin = 10^ordMin;
xMax = 10^ordMax;
xlim([xMin xMax]);
set(ax,'LineWidth',2);
% probPlot_min = min(probPlot_min_arr);
% probPlot_max = max(probPlot_max_arr);
% probPlotLimits = [probPlot_min probPlot_max];
% ylim(probPlotLimits);
prob_min = min(prob_min_arr);
prob_max = max(prob_max_arr);
probPlot_min = getTransform(prob_min);
probPlot_max = getTransform(prob_max);
ylim([probPlot_min probPlot_max]);

grid off;
% grid on;
% Legend
legend_cell = {File.Data(:).Name};
legend(legend_cell,'location','southeast');
if saveFig
    title(WEIBULL_TITLE);
    horzLine = yline(yCharLife,'--',charLife_annot,...
                'LineWidth',lineWidth,...
                'FontSize',FONT_SIZE-2,...
                'LabelHorizontalAlignment','left', ...
                'HandleVisibility','off');
    ftFilename = [name '_Weibull_FT_annot.tif'];
    ftFilepath = fullfile(folder,ftFilename);
    exportPlot(figWeibull,ftFilepath,600);
    title('');
    delete(horzLine);
    ftFilename = [name '_Weibull_FT.tif'];
    ftFilepath = fullfile(folder,ftFilename);
    exportPlot(figWeibull,ftFilepath,600);
    fprintf('\n');
end

% Box Plot
for boxAllNum = boxComplile_arr
    figBox = figure(boxAllNum);
    ax = gca;
    ylim('tickaligned');
    drawnow;
    yRange = ylim;
    % yMin = yRange(1);
    yMax = yRange(2);
    if boxAllNum == 1
        fprintf('Figure %d: Failure Time Box Plot Compiled\n',boxAllNum);
        ylabel('Failure Time (s)');
        ordMax = floor(log10(yMax));
        if ordMax >= 3
            yMax = 10^ordMax;
            ax.YAxis.Exponent = ordMax;
            ylim([0 yMax]);
        end
        if saveFig
            title(FAILURE_TIME_NAME);
            ftFilename = sprintf('%s_BoxPlot_FT_annot.tif',name);
            ftFilepath = fullfile(folder,ftFilename);
            exportPlot(figBox,ftFilepath,600);
            title('');
            ftFilename = sprintf('%s_BoxPlot_FT.tif',name);
            ftFilepath = fullfile(folder,ftFilename);
            exportPlot(figBox,ftFilepath,600);
            fprintf('\n');
        end
    else
        fprintf('Figure %d: Voltage Failure Box Plot Compiled\n',boxAllNum);
        if saveFig
            title(VOLTAGE_FAILURE_NAME);
            vfFilename = sprintf('%s_BoxPlot_VF_annot.tif',name);
            vfFilepath = fullfile(folder,vfFilename);
            exportPlot(figBox,vfFilepath,600);
            title('');
            vfFilename = sprintf('%s_BoxPlot_VF.tif',name);
            vfFilepath = fullfile(folder,vfFilename);
            exportPlot(figBox,vfFilepath,600);
            fprintf('\n');
        end
    end
end

end