function [File,isQuit] = runFitting(File,saveFig)
%% Constants
% Values
N_CHANGE = 0.8;

% Processing
FONT_SIZE = 20;

% Figure
WINDOW_HEADER = 100;
FIG_SHIFT = 20;

% Video
FIG_WIDTH_VID = 1920;
FIG_HEIGHT_VID = 480;

% MATLAB
MATLAB_COLOR = {...
    '#0072BD',...   % blue
    '#D95319',...   % orange
    '#EDB120',...   % yellow
    '#7E2F8E',...   % purple
    '#77AC30',...   % green
    '#4DBEEE',...   % cyan
    '#A2142F'};     % maroon

%% Variables
% Initialization
isQuit = false;
numOfCateg = length(File.Data);
lifetime_arr = zeros(numOfCateg,1);
for categNum = 1:numOfCateg
    lifetime = File.Data(categNum).Scale.Value;
    lifetime_arr(categNum) = lifetime;
end
xExpon = floor(log10(max(lifetime_arr)));
voltageStep_arr = [File.Data(:).VoltageStep]';
timeStep_arr = [File.Data(:).TimeStep]';

% Structure
Algorithm = struct( ...
    'Value',[], ...
    'Data',[]);

% Screen
[screenX,~,~,screenHeight,numOfMonitors] = getScreenSize2();
figPosX = screenX(numOfMonitors);
screenHeight_use = screenHeight(numOfMonitors);
figPosY = screenHeight_use - WINDOW_HEADER;

% Figure
lineWidth = 1.5;
markerSize = 100;
color1 = MATLAB_COLOR{1};
color2 = MATLAB_COLOR{2};
color3 = MATLAB_COLOR{3};
colorBlack = 'k';
legend_cell = {File.Data(:).Name};
numOfFigs = getNumOfFigs();
figNum = numOfFigs + 1;
fprintf('Figure %d: Fitting\n',figNum);
figFit = figure(figNum);
figFit_tile = tiledlayout('horizontal', ...
    'TileSpacing','loose', ...
    'Padding','compact');
set(figFit,'Color','w');
title(figFit_tile,'{\bfFitting Method}','FontSize',FONT_SIZE);
move = (figNum - 1) * FIG_SHIFT;
figPosX_new = figPosX + move;
figPosY_new = figPosY - move - FIG_HEIGHT_VID;
set(figFit,'Position',[figPosX_new,figPosY_new,FIG_WIDTH_VID,FIG_HEIGHT_VID]);

% Video
if saveFig
    name = File.Name;
    folder = File.Path;
    fitVid_filename = [name '_FitVideo.mp4',];
    fitVid_filepath = fullfile(folder,fitVid_filename);
    if isfile(fitVid_filepath)
        delete(fitVid_filepath);
    end
    frameRate = 5;
    vidQuality = 100;
    fitVid = VideoWriter(fitVid_filepath,'MPEG-4');
    fitVid.FrameRate = frameRate;
    fitVid.Quality = vidQuality;
    open(fitVid);
end

%% Fitting
% xDiff = 1e-3;
slopeCheck = 1e-12;
% for checkNum = 1:2
for checkNum = 1:2
    nFound = false;
    n = 0;
    nDiff = 0.1;
    nDiff_new = nDiff;
    n_arr = [];
    slope_arr = [];
    damage_arr = zeros(1,numOfCateg);
    % logDamage_arr = zeros(1,numOfCateg);
    while ~nFound
        fprintf('n = %.9f;\t\t',n);
        startTime = tic;
        n_arr_alloc = [n_arr;n];
        n_arr = n_arr_alloc;
        for categNum = 1:numOfCateg            
            lifetime = lifetime_arr(categNum);
            timeStep = timeStep_arr(categNum);
            voltageStep = voltageStep_arr(categNum);
            categName = legend_cell{categNum};
            fprintf('%s ',categName);
            damage = getDamage(lifetime,timeStep,voltageStep,n);
            % logDamage = log(damage);
            fprintf('D = %.3e;\t',damage);
            damage_arr(categNum) = damage;
            % logDamage_arr(categNum) = logDamage;
        end
        yExpon = floor(log10(max(damage_arr)));
        [slope,intercept,~] = getLinReg(lifetime_arr,damage_arr);
        fprintf('m = %.3e;\t\t',slope); 
        slope_arr_alloc = [slope_arr;slope];
        slope_arr = slope_arr_alloc;
       
        if checkNum == 2
            % Plot
            figure(figNum);
            % Tile 1
            ax1 = nexttile(1);
            scatter(lifetime_arr,damage_arr, ...
                'Marker','+', ...
                'MarkerEdgeColor',color1, ...
                'LineWidth',lineWidth, ...
                'SizeData',markerSize);
            hold on;
            line = slope * lifetime_arr + intercept;
            plot(lifetime_arr,line, ...
                'LineStyle','--', ...
                'Color',color3, ...
                'LineWidth',lineWidth);
            str = sprintf('{\\itn} = %.3g, slope = %.3g',n,slope);
            subtitle(ax1,str);
            if xExpon >= 3
                ax1.XAxis.Exponent = 3;
            end
            if yExpon >= 3
                ax1.YAxis.Exponent = yExpon;
            end
            ylim('tickaligned');
            xlabel('Lifetime (s)');
            ylabel('ln(Cumulative Damage)');
            set(ax1,'FontSize',FONT_SIZE);
            set(ax1,'LineWidth',lineWidth);
            box on;
            drawnow;
            hold off;
            % Tile 2
            ax2 = nexttile(2);
            plot(n_arr,slope_arr, ...
                'Color',color2, ...
                'LineWidth',lineWidth);
            ylim('tickaligned');
            xlabel('Acceleration Constant');
            ylabel('Regression Slope');
            set(ax2,'FontSize',FONT_SIZE);
            set(ax2,'LineWidth',lineWidth);
            box on;
            drawnow;
            % Video
            if saveFig
                % Capture the frame
                frame = getframe(figFit);

                % Write the frame to the video
                writeVideo(fitVid,frame);
            end
        end

        switch checkNum
            case 1
                slope_abs = abs(slope);
                if slope < 0
                    nDiff = nDiff * N_CHANGE;
                    n = n - nDiff;
                    fprintf('dn = %.3e',nDiff);
                else
                    n = n + nDiff;
                    fprintf('dn = %.3e',nDiff);
                end
                if slope_abs < slopeCheck
                    nFit = n;
                    nFound = true;
                end
            case 2
                %                 nStop = round(nFit,-1);
                nStop = ceil(nFit);
                if n >= nStop
                    figure(figFit);
                    if nStop ~= 0
                        xlim([0 floor(nStop)]);
                        ylim('tickaligned');
                    end
                    % Tile 1
                    for categNum = 1:numOfCateg
                        lifetime = lifetime_arr(categNum);
                        timeStep = timeStep_arr(categNum);
                        voltageStep = voltageStep_arr(categNum);
                        damage = getDamage(lifetime,timeStep,voltageStep,nFit);
                        damage_arr(categNum) = damage;
                    end
                    yExpon = floor(log10(max(damage_arr)));
                    [slope,intercept,~] = getLinReg(lifetime_arr,damage_arr);
                    ax1 = nexttile(1);
                    scatter(lifetime_arr,damage_arr, ...
                        'Marker','+', ...
                        'MarkerEdgeColor',color1, ...
                        'LineWidth',lineWidth, ...
                        'SizeData',markerSize);
                    hold on;
                    line = slope * lifetime_arr + intercept;
                    plot(lifetime_arr,line, ...
                        'LineStyle','--', ...
                        'Color',colorBlack, ...
                        'LineWidth',lineWidth);
                    str = sprintf('{\\itn} = %.3g, slope = %.3g',nFit,slope);
                    subtitle(ax1,str);
                    if xExpon >= 3
                        ax1.XAxis.Exponent = 3;
                    end
                    if yExpon >= 3
                        ax1.YAxis.Exponent = yExpon;
                    end
                    ylim('tickaligned');
                    xlabel('Lifetime (s)');
                    ylabel('Cumulative Damage');
                    avg = mean(damage_arr);
                    sd = std(damage_arr);
                    fract = sd / avg;
                    if fract < 0.1
                        factor = 10 * abs(floor(log10(factor)));
                        yMin = floor(min(damage_arr) * factor) / factor;
                        yMax = ceil(max(damage_arr) * factor) / factor;
                        ylim([yMin yMax]);
                    end
                    set(ax1,'FontSize',FONT_SIZE);
                    set(ax1,'LineWidth',lineWidth);
                    box on;
                    drawnow;

                    % Tile 2
                    nexttile(2);
                    plot(n_arr,slope_arr, ...
                        'Color',color2, ...
                        'LineWidth',lineWidth);
                    hold on;
                    xlabel('Acceleration Constant');
                    ylabel('Regression Slope');
                    set(ax2,'FontSize',FONT_SIZE);
                    set(ax2,'LineWidth',lineWidth);
                    yline(0,'k:', ...
                        'HandleVisibility','off');
                    scatter(nFit,0,'k.',...
                        'SizeData',100,...
                        'LineWidth',2);
                    nFit_text = sprintf('  {\\itn}_{acc} = %.2f  \n',nFit); % text
                    text(nFit,0,nFit_text,... % annotation
                        'FontSize',FONT_SIZE,...
                        'HorizontalAlignment','left');
                    box on;
                    drawnow;
                    hold off;

                    % Export
                    if saveFig
                        % Capture the frame
                        drawnow;
                        frame = getframe(figFit);
                        
                        % Write the frame to the video
                        writeVideo(fitVid,frame);
                        fprintf('Exporting "%s"...',fitVid_filename);
                        startTime = tic;
                        close(fitVid);
                        [endTime,unit] = getEndTime(startTime);
                        fprintf('OK (%.2f %s)\n',endTime,unit);

                        % Figure
                        title(figFit_tile,'');
                        subtitle(ax1,'');
                        title(ax2,'Fitting Method');
                        fitFilename = [name '_Fit_annot.tif'];
                        fitFilepath = fullfile(folder,fitFilename);
                        exportPlot(ax2,fitFilepath,600);
                        title('');
                        fitFilename = [name '_Fit.tif'];
                        fitFilepath = fullfile(folder,fitFilename);
                        exportPlot(ax2,fitFilepath,600);
                    end
                    break;
                else
                    n = n + nDiff_new;
                end
        end
        [endTime,unit] = getEndTime(startTime);
        fprintf('\t\t(%.2f %s)',endTime,unit);
        fprintf('\n');
    end
    [endTime,unit] = getEndTime(startTime);
    fprintf('\t\t(%.2f %s)',endTime,unit);
    fprintf('\n');
end
fprintf('Fit n = %.6f\n',nFit);
Algorithm.Value = nFit;
Algorithm.Data = [n_arr slope_arr];
File.Scan = Algorithm;

end