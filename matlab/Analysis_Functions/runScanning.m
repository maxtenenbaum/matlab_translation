function [File,isQuit] = runScanning(File,saveFig)
%% Constants
% Values
ACCURACY = 12;

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
timeStep_arr = [File.Data(:).TimeStep];

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
legend_cell = {File.Data(:).Name};
numOfFigs = getNumOfFigs();
figNum = numOfFigs + 1;
fprintf('Figure %d: Scanning\n',figNum);
figScan = figure(figNum);
figScan_tile = tiledlayout('horizontal', ...
    'TileSpacing','loose', ...
    'Padding','compact');
set(figScan,'Color','w');
title(figScan_tile,'{\bfScanning Method}','FontSize',FONT_SIZE);
move = (figNum - 1) * FIG_SHIFT;
figPosX_new = figPosX + move;
figPosY_new = figPosY - move - FIG_HEIGHT_VID;
set(figScan,'Position',[figPosX_new,figPosY_new,FIG_WIDTH_VID,FIG_HEIGHT_VID]);

% Algorithm Initialization
nDiff_scan = 0.1;
nScan_max = 5 / nDiff_scan;
nList = nDiff_scan:nDiff_scan:nScan_max;
len = length(nList);
logDamage_arr = zeros(1,numOfCateg);
comboList = getComboList(numOfCateg);
numOfCombo = length(comboList);
n_arr = zeros(len,1);
sum_arr = zeros(len,1);

% Video
if saveFig
    name = File.Name;
    folder = File.Path;
    scanVid_filename = [name '_ScanVideo.mp4'];
    scanVid_filepath = fullfile(folder,scanVid_filename);
    if isfile(scanVid_filepath)
        delete(scanVid_filepath);
    end
    nList_len = length(nList);
    duration = 12;
    frameRate = floor(nList_len / duration);
    vidQuality = 100;
    scanVid = VideoWriter(scanVid_filepath,'MPEG-4');
    scanVid.FrameRate = frameRate;
    scanVid.Quality = vidQuality;
    open(scanVid);
end

%% Scanning
% Algorithm
idx = 0;
for n = nList
    fprintf('n = %.9f;\t\t',n);
    startTime = tic;
    for categNum = 1:numOfCateg
        lifetime = lifetime_arr(categNum);
        timeStep = timeStep_arr(categNum);
        voltageStep = voltageStep_arr(categNum);
        categName = legend_cell{categNum};
        fprintf('%s ',categName);
        damage = getDamage(lifetime,timeStep,voltageStep,n);
        logDamage = log10(damage);
        fprintf('logD = %.3e;\t\t',logDamage);
        logDamage_arr(categNum) = logDamage;
    end

    comboDiff_arr = zeros(1,numOfCombo);
    for comboNum = 1:numOfCombo
        choice1_idx = comboList(comboNum,1);
        choice2_idx = comboList(comboNum,2);
        choice1 = logDamage_arr(choice1_idx);
        choice2 = logDamage_arr(choice2_idx);
        comboDiff = abs(choice2 - choice1) / sqrt(n^2 + 1);
        comboDiff_arr(comboNum) = comboDiff;
    end
    sum_val = sum(comboDiff_arr);
    idx = idx + 1;
    n_arr(idx) = n;
    sum_arr(idx) = sum_val;
    fprintf('sum = %.6e',sum_val);
    [endTime,unit] = getEndTime(startTime);
    fprintf('\t\t(%.2f %s)',endTime,unit);
    fprintf('\n');

    % Plot
    figure(figNum);
    % Tile 1
    ax1 = nexttile(1);
    scatter(lifetime_arr,logDamage_arr, ...
        'Marker','+', ...
        'MarkerEdgeColor',color1, ...
        'LineWidth',lineWidth, ...
        'SizeData',markerSize);
    str = sprintf('{\\itn} = %.3g, {\\its} = %.4g',n,sum_val);
    subtitle(ax1,str);
    if xExpon >= 3
        ax1.XAxis.Exponent = 3;
    end
    ylim('tickaligned');
    xlabel('Lifetime (s)');
    ylabel('log(Cumulative Damage)');
    set(ax1,'FontSize',FONT_SIZE);
    set(ax1,'LineWidth',lineWidth);
    box on;
    drawnow;
    % Tile 2
    ax2 = nexttile(2);
    n_tf = nList <= n;
    n_plot = nList(n_tf)';
    sum_plot = sum_arr(n_tf);
    plot(n_plot,sum_plot, ...
        'Color',color2, ...
        'LineWidth',lineWidth);
    ylim('tickaligned');
    yline(0,':');
    xlabel('Acceleration Constant');
    ylabel('Discrepancy');
    set(ax2,'FontSize',FONT_SIZE);
    set(ax2,'LineWidth',lineWidth);
    box on;
    hold off;
    drawnow;
    % Video
    if saveFig
        % Capture the frame
        frame = getframe(figScan);
    
        % Write the frame to the video
        writeVideo(scanVid,frame);
    end
end
sum_min = min(sum_arr);
sum_min_idx = find(sum_arr == sum_min,1);
nScan = nList(sum_min_idx);
fprintf('Scan n = %.6f\n',nScan);

n = 1;
nDiff_fast = 0.1;
nFound = false;
while nFound == false
    sumMin_fast = [];
    nSum = [];
    nPrev = [];
    while isempty(nSum)
        fprintf('n = %.9f;\t\t',n);
        startTime = tic;
        for categNum = 1:numOfCateg
            lifetime = lifetime_arr(categNum);
            timeStep = timeStep_arr(categNum);
            voltageStep = voltageStep_arr(categNum);
            categName = legend_cell{categNum};
            fprintf('%s ',categName);
            damage = getDamage(lifetime,timeStep,voltageStep,n);
            logDamage = log10(damage);
            fprintf('logD = %.3e;\t\t',logDamage);
            logDamage_arr(categNum) = logDamage;
        end

        comboDiff_arr = zeros(1,numOfCombo);
        for comboNum = 1:numOfCombo
            choice1_idx = comboList(comboNum,1);
            choice2_idx = comboList(comboNum,2);
            choice1 = logDamage_arr(choice1_idx);
            choice2 = logDamage_arr(choice2_idx);
            comboDiff = abs(choice2 - choice1) / sqrt(n^2 + 1);
            comboDiff_arr(comboNum) = comboDiff;
        end

        sum_val = sum(comboDiff_arr);
        fprintf('sum = %.6e',sum_val);
        [endTime,unit] = getEndTime(startTime);
        fprintf('\t\t(%.2f %s)',endTime,unit);
        fprintf('\n');
        if ~isempty(nPrev)
            if sum_val > sumPrev
                nSum = nPrev;
            end
        end
        nPrev = n;
        sumPrev = sum_val;
        n = n + nDiff_fast;
    end
    roundPlace = abs(log10(nDiff_fast));
    if roundPlace >= ACCURACY
        nScan_fast = nSum;
        sumMin_fast = sum_val;
        nFound = true;
    else
        n = round(nSum,roundPlace) - nDiff_fast;
        nDiff_fast = nDiff_fast / 10;
    end
end
fprintf('Algorithmic Scan n = %.6f\n',nScan_fast);
figure(figScan);
% Tile 1
ax1 = nexttile(1);
scatter(lifetime_arr,logDamage_arr, ...
    'Marker','+', ...
    'MarkerEdgeColor',color1, ...
    'LineWidth',lineWidth, ...
    'SizeData',markerSize);
str = sprintf('{\\itn} = %.3g, {\\its} = %.4g',nScan_fast,sumMin_fast);
subtitle(ax1,str);
if xExpon >= 3
    ax1.XAxis.Exponent = 3;
end
ylim('tickaligned');
xlabel('Lifetime (s)');
ylabel('log(Cumulative Damage)');
set(ax1,'FontSize',FONT_SIZE);
set(ax1,'LineWidth',lineWidth);
box on;
% Tile 2
ax2 = nexttile(2);
hold on;
scatter(nScan_fast,sumMin_fast,'k.',...
    'SizeData',100,...
    'LineWidth',1.5);
nScan_char = sprintf('  {\\itn}_{acc} = %.2f\n\n\n',nScan_fast);
text(nScan_fast,sumMin_fast,nScan_char,...
    'FontSize',FONT_SIZE); hold off; % annotation
xline(nScan_fast,'k:', ...
    'HandleVisibility','off');
box on;

% Export
Algorithm.Value = nScan_fast;
Algorithm.Data = [n_arr sum_arr];
File.Scan = Algorithm;
if saveFig
    % Capture the frame
    drawnow;
    frame = getframe(figScan);
    
    % Write the frame to the video
    writeVideo(scanVid,frame);
    fprintf('Exporting "%s"...',scanVid_filename);
    startTime = tic;
    close(scanVid);
    [endTime,unit] = getEndTime(startTime);
    fprintf('OK (%.2f %s)\n',endTime,unit);
    
    % Figure
    title(figScan_tile,'');
    subtitle(ax1,'');
    title(ax2,'Scanning Method');
    scanFilename = [name '_Scan_annot.tif'];
    scanFilepath = fullfile(folder,scanFilename);
    exportPlot(ax2,scanFilepath,600);
    title('');
    scanFilename = [name '_Scan.tif'];
    scanFilepath = fullfile(folder,scanFilename);
    exportPlot(ax2,scanFilepath,600);
end

end