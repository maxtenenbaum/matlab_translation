function [File,isQuit] = runAlgorithm(File,saveFig)
%% Constants
% Values
N_CHANGE = 0.8;
TOLERANCE = 1e-4;
ACCURACY = 12;

% Processing
MIN_TO_S = 60;
FONT_SIZE = 20;

% Figure
FIG_WIDTH = 960;
WINDOW_HEADER = 80;
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
retrieving = true;
confirmFile = false;
filename_cell = {};
numOfFiles_arr = [];
vf_cell = {};
ft_cell = {};
timeStep_arr = [];
voltageStep_arr = [];
compiledSteps = {};
legend_cell = {};

% Screen
[screenX,~,~,screenHeight,numOfMonitors] = getScreenSize2();
figPosX = screenX(numOfMonitors);
screenHeight_use = screenHeight(numOfMonitors);
figPosY = screenHeight_use - WINDOW_HEADER;

%% Variables
isQuit = false;
numOfCateg = length(File.Data);
lifetime_arr = zeros(numOfCateg,1);
breakdown_arr = zeros(numOfCateg,1);
voltageStep_arr = zeros(numOfCateg,1);
timeStep_arr = zeros(numOfCateg,1);
numOfFullSteps_arr = zeros(numOfCateg,1);
lastStep_arr = zeros(numOfCateg,1);

%% Scanning
for categNum = 1:numOfCateg
    lifetime = File.Data(categNum).Statistics.Time.Weibull.Scale.Value;
    breakdown = File.Data(categNum).Statistics.Time.Weibull.Shape.Value;
    voltageStep = File.Data(categNum).VoltageStep;
    timeStep = File.Data(categNum).TimeStep;
    timeStep_s = timeStep * MIN_TO_S;
    lastStep = rem(lifetime,timeStep_s);
    breakdownPlace = -floor(log10(voltageStep));
    breakdown_char = sprintf('%g',breakdown);
    decPoint_idx = strfind(breakdown_char,'.');
    trunc_idx = decPoint_idx + breakdownPlace;
    breakdown_char_trunc = breakdown_char(1:trunc_idx);
    breakdown_trunc = str2double(breakdown_char_trunc);
    numOfFullSteps = breakdown_trunc / voltageStep - 1;

    lifetime_arr(categNum) = lifetime;
    breakdown_arr(categNum) = breakdown_trunc;
    voltageStep_arr(categNum) = voltageStep;
    timeStep_arr(categNum) = timeStep_s;
    lastStep_arr(categNum) = lastStep;
    numOfFullSteps_arr(categNum) = numOfFullSteps;
end
fprintf('\n');

% Starting Video
if saveFig
    scanVid_filename = [name 'vid_scan.mp4'];
    scanVid_filepath = fullfile(folder,scanVid_filename);
    scanVid = VideoWriter(scanVid_filepath);
    scanVid.FrameRate = 0.5;
    scanVid.Quality = 100;
    open(scanVid);
end

% Figure
numOfFigs = getNumOfFigs();
figNum = numOfFigs + 1;
fprintf('Figure %d: Scanning\n',figNum);
figScan = figure(figNum);
figScan_tile = tiledlayout(2,1, ...
    'TileSpacing','tight', ...
    'Padding','compact');
clf(figScan);
box on;
title('Scanning');
xlabel('{\itn}');
ylabel('Discrepancy');
move = (figNum - 1) * FIG_SHIFT;
figPosX_new = figPosX + move;
figPosY_new = figPosY - move - FIG_HEIGHT_VID;
set(figScan,'Position',[figPosX_new,figPosY_new,FIG_WIDTH_VID,FIG_HEIGHT_VID]);
ax = gca;
set(ax,'FontSize',FONT_SIZE);
set(ax,'LineWidth',lineWidth);
varLine = animatedline;
sumLine = animatedline;
varColor = MATLAB_COLOR{1};
sumColor = MATLAB_COLOR{2};
sumLine.Color = sumColor;
sumLine.LineWidth = lineWidth;
sum_arr = [];

% Starting Algorithm
nDiff_scan = 0.1;
nList = 1:nDiff_scan:5*10;
logD_arr = zeros(1,numOfCateg);
% logD_mat = double.empty(0,numOfCateg);
choiceList = 1:numOfCateg;
comboList = nchoosek(choiceList,2);
numOfCombo = length(comboList);

for n = nList
    fprintf('n = %.9f;\t\t',n);
    for categNum = 1:numOfCateg
        breakdown = breakdown_arr(categNum);
        voltageStep = voltageStep_arr(categNum);
        timeStep = timeStep_arr(categNum);
        lastStep = lastStep_arr(categNum);
        numOfFullSteps = numOfFullSteps_arr(categNum);
        categName = legend_cell{categNum};

        fprintf('%s ',categName);
        syms k;
        sumEqn = timeStep * (voltageStep*(k-1))^n;
        summing = symsum(sumEqn,k,1,numOfFullSteps);
        lastStep_calc = lastStep * breakdown^n;
        D = summing + lastStep_calc;
        logD = log10(D);
        fprintf('logD = %.3e;\t\t',logD);
        logD_arr(categNum) = logD;
    end

    diff_arr = zeros(1,numOfCombo);
    for comboNum = 1:numOfCombo
        choice1_idx = comboList(comboNum,1);
        choice2_idx = comboList(comboNum,2);
        choice1 = logD_arr(choice1_idx);
        choice2 = logD_arr(choice2_idx);
        diff = abs(choice2 - choice1) / sqrt(n^2 + 1);
        diff_arr(comboNum) = diff;
    end
    sum_val = sum(diff_arr);
    sum_arr_alloc = [sum_arr;sum_val];
    sum_arr = sum_arr_alloc;


    fprintf('Figure %d: Scanning\n',figNum);
    figure(figNum);
    nexttile(2);
    addpoints(sumLine,n,sum_val);
    leg.AutoUpdate = 'off';
    drawnow;
    fprintf('\n');
end
hold on;

sum_min = min(sum_arr);
sum_min_idx = find(sum_arr == sum_min,1);
nScan = nList(sum_min_idx);
fprintf('Scan n = %.6f\n\n',nScan);

n = 1;
nDiff_fast = 0.1;
nFound = false;
while nFound == false
    nSum = [];
    nPrev = [];
    while isempty(nSum) && isempty(nVar)
        fprintf('n = %.9f;\t\t',n);
        for categNum = 1:numOfCateg
            lifetime = lifetime_arr(categNum);
            breakdown = breakdown_arr(categNum);
            voltageStep = voltageStep_arr(categNum);
            timeStep = timeStep_arr(categNum);
            lastStep = lastStep_arr(categNum);
            numOfFullSteps = numOfFullSteps_arr(categNum);
            categName = legend_cell{categNum};

            fprintf('%s ',categName);
            sumEqn = timeStep * (voltageStep*(k-1))^n;
            syms k;
            summing = symsum(sumEqn,k,1,numOfFullSteps);
            lastStep_calc = lastStep * breakdown^n;
            D = summing + lastStep_calc;
            logD = log10(D);
            fprintf('logD = %.3e;\t\t',logD);
            logD_arr(categNum) = logD;
        end

        diff_arr = zeros(1,numOfCombo);
        for comboNum = 1:numOfCombo
            choice1_idx = comboList(comboNum,1);
            choice2_idx = comboList(comboNum,2);
            choice1 = logD_arr(choice1_idx);
            choice2 = logD_arr(choice2_idx);
            diff = abs(choice2 - choice1) / sqrt(n^2 + 1);
            diff_arr(comboNum) = diff;
        end

        sum_val = sum(diff_arr);
        fprintf('sum = %.6e\t\t',sum_val);
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
        nFound = 1;
    else
        n = round(nSum,roundPlace) - nDiff_fast;
        nDiff_fast = nDiff_fast / 10;
    end
end
fprintf('\nAlgorithmic Scan n = %.6f\n',nScan_fast);

scatter(nScan_fast,sum_min,'k.',...
    'SizeData',100,...
    'LineWidth',1.5); hold on;
nScan_char = sprintf('  {\\itn}_{acc} = %.1f',nScan_fast);
nScan_text = text(nScan,sum_min,nScan_char,...
    'FontSize',FONT_SIZE); hold off; % annotation
% annot = xline(nScan,'k:',nScan_char,...
%     'FontSize',14,...
%     'LabelHorizontalAlignment','center',...
%     'LabelVerticalAlignment','middle');
xline(nScan,'k:');

scanAx = nexttile(2);
if saveFig
    scanFilename = [name '_ALL_Scan_annot.tif'];
    scanFilepath = fullfile(folder,scanFilename);
    exportPlot(scanAx,scanFilepath,400);
    fprintf('\n');
end

title('');
if saveFig
    scanFilename = [name '_ALL_Scan.tif'];
    scanFilepath = fullfile(folder,scanFilename);
    exportPlot(scanAx,scanFilepath,400);
    fprintf('\n');
end

%% Fitting
% Starting Video
if saveFig
    scanFit_filename = [name 'vid_fit.mp4'];
    scanFit_filepath = fullfile(folder,scanVid_filename);
    scanFit = VideoWriter(scanVid_filepath);
    scanFit.FrameRate = 0.5;
    scanFit.Quality = 100;
    open(scanFit);
end

% Figure
figNum = figNum + 1;
fprintf('Figure %d: Fitting\n',figNum);
figFit = figure(figNum);
figFit_tile = tiledlayout(2,1, ...
    'TileSpacing','tight', ...
    'Padding','compact');
clf(figFit);
slopeLine = animatedline;
lineColor = MATLAB_COLOR{1};
slopeLine.Color = lineColor;
slopeLine.LineWidth = lineWidth;
title('Fitting');
xlabel('{\itn}');
ylabel('Regression Slope');
move = (figNum - 1) * FIG_SHIFT;
figPosX_new = figPosX + move;
figPosY_new = figPosY - move - FIG_HEIGHT_VID;
set(figFit,'Position',[figPosX_new,figPosY_new,FIG_WIDTH_VID,FIG_HEIGHT_VID]);
ax = gca;
set(ax,'FontSize',FONT_SIZE);
set(ax,'LineWidth',2);

% xDiff = 1e-3;
slopeCheck = 1e-6;
slope_arr = [];
% for checkNum = 1:2
for checkNum = 1:2
    nFound = false;
    n = 0;
    nDiff = 0.1;
    nDiff_new = nDiff;
    logD_arr = zeros(1,numOfCateg);
    while ~nFound
        fprintf('n = %.9f;\t\t',n);
        for categNum = 1:numOfCateg
            breakdown = breakdown_arr(categNum);
            voltageStep = voltageStep_arr(categNum);
            timeStep = timeStep_arr(categNum);
            lastStep = lastStep_arr(categNum);
            numOfFullSteps = numOfFullSteps_arr(categNum);
            categName = legend_cell{categNum};

            fprintf('%s ',categName);
            sumEqn = timeStep * (voltageStep*(k-1))^n;
            syms k;
            summing = symsum(sumEqn,k,1,numOfFullSteps);
            lastStep_calc = lastStep * breakdown^n;
            D = summing + lastStep_calc;
            fprintf('D = %.3e;\t',D);
            logD_arr(categNum) = D;
        end

        fitopts = fitoptions('Method','LinearLeastSquares');
        fitting = fit(lifetime_arr',logD_arr','poly1',fitopts);
        coeff = coeffvalues(fitting);
        slope = coeff(1);
        fprintf('m = %.3e;\t\t',slope);
        %         intercept = coeff(2);
        if checkNum == 2
            slope_arr_alloc = [slope_arr,slope];
            slope_arr = slope_arr_alloc;
        end

        if checkNum == 2
            box on;
            addpoints(slopeLine,n,slope);
            %             yFitting = fitting(xFitting);
            %             plot(xFitting,yFitting,'k--'); hold off;
            drawnow;
        end

        switch checkNum
            case 1
                slope_abs = abs(slope);
                if slope < 0
                    nDiff = nDiff * N_CHANGE;
                    n = n - nDiff;
                    fprintf('dn = %.3e;\n',nDiff);
                else
                    n = n + nDiff;
                    fprintf('dn = %.3e;\n',nDiff);
                end
                if slope_abs < slopeCheck
                    nFit = n;
                    nFound = true;
                    fprintf('\nFit n = %.6f\n',nFit);
                end
            case 2
                %                 nStop = round(nFit,-1);
                nStop = ceil(nFit);
                if n >= nStop
                    fprintf('\n');
                    fprintf('\n');
                    nMax = round(nFit,1) + 0.1;
                    yMax = max(slope_arr);
                    yMin = min(slope_arr);
                    if yMin < 0
                        yMax_pow = floor(real(log10(yMax)));
                        yMin_pow_new = yMax_pow - 1;
                        yMin_new = -1 * 10^yMin_pow_new;
                        yMax_coeff = ceil(yMax / 10^yMax_pow);
                        yMax_new = yMax_coeff * 10^yMax_pow;
                    else
                        yMin_new = 0;
                        yMax_new = inf;
                    end
                    ylim([yMin_new yMax_new]);
                    if nStop ~= 0
                        xlim([0 floor(nStop)]);
                    end
                    yline(0,'k:'); hold on;
                    scatter(nFit,0,'k.',...
                        'SizeData',100,...
                        'LineWidth',2);
                    nFit_text = sprintf('  {\\itn}_{acc} = %.1f  \n',nFit); % text
                    nFit_annot = text(nFit,0,nFit_text,... % annotation
                        'FontSize',FONT_SIZE,...
                        'HorizontalAlignment','right');
                    hold off;
                    fitAx = nexttile(2);
                    if saveFig
                        fitFilename = [name '_ALL_Fit_annot.tif'];
                        fitFilepath = fullfile(folder,fitFilename);
                        exportPlot(fitAx,fitFile,400);
                        fprintf('\n');
                    end

                    title('');
                    if saveFig
                        fitFilename = [name '_ALL_Fit.tif'];
                        fitFilepath = fullfile(folder,fitFilename);
                        exportPlot(fitAx,fitFile,400);
                        fprintf('\n');
                    end
                    break;
                else
                    n = n + nDiff_new;
                    fprintf('\n');
                end
        end
    end
end
fprintf('\n');

end