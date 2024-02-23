try
    clear; clc; close all;
catch
    delete(findall(groot,'Type','figure'));
end
warning('off','all');
fprintf('PROGRAM STARTED.\n\n');

%% Constants
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

CURRENT_THRESH = 1e-9;
S_TO_MIN = 1 / 60;
ANNOT_DIM = [.15 .65 .2 .2];
% REG_THRESH = 0.00;
KILO_MAG = 3;
MEGA_MAG = 6;
GIGA_MAG = 9;
TERA_MAG = 12;
PETA_MAG = 15;
N_TO_KILO = 1e-3;
N_TO_MEGA = 1e-6;
N_TO_GIGA = 1e-9;
N_TO_TERA = 1e-12;
N_TO_PETA = 1e-15;
WINDOW_HEADER = 80;
FIG_POS_X = 1;
FIG_SHIFT = 20;

% Linear fit
LINREG_SLOPE_IDX = 1;       % index for slope in polyfit
LINREG_INTERCEPT_IDX = 2;   % index for y-intercept in polyfit

% Dialog
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
BUTTON_QUIT = 'Quit';
opts.Default = 'true';       % option default
opts.Interpreter = 'tex';   % option LaTeX
DEFAULT_POSITION = 'southeast';
POSITION_LIST = {...
    'north',...
    'south',...
    'east',...
    'west',...
    'northeast',...
    'northwest',...
    'southeast',...
    'southwest',...
    'northoutside',...
    'southoutside',...
    'eastoutside',...
    'westoutside',...
    'northeastoutside',...
    'northwestoutside',...
    'southeastoutside',...
    'southwestoutside',...
    'best',...
    'bestoutside',...
    'layout',...
    'n1'};
DESCRIPTION_LIST = {...
    'Inside top of axes',...
    'Inside bottom of axes',...
    'Inside right of axes',...
    'Inside left of axes',...
    'Inside top-right of axes (default for 2-D axes)',...
    'Inside top-left of axes',...
    'Inside bottom-right of axes',...
    'Inside bottom-left of axes',...
    'Above the axes',...
    'Below the axes',...
    'To the right of the axes',...
    'To the left of the axes',...
    'Outside top-right corner of the axes (default for 3-D axes)',...
    'Outside top-left corner of the axes',...
    'Outside bottom-right corner of the axes',...
    'Outside bottom-left corner of the axes',...
    'Inside axes where least conflict occurs with the plot data at the time that you create the legend. If the plot data changes, you might need to reset the location to "best".',...
    'Outside top-right corner of the axes (when the legend has a vertical orientation) or below the axes (when the legend has a horizontal orientation)',...
    'A tile in a tiled chart layout. To move the legend to a different tile, set the Layout property of the legend.',...
    'Determined by Position property. Use the Position property to display the legend in a custom location.'};

%% Find Functions Folder
findFunctions();

%% Variables
% Import
fprintf('Selecting file...');
[filename,folder] = uigetfile('*.mat','IV File');
if folder == 0
    return;
end
fprintf('"%s"...',filename);
file = fullfile(folder,filename);
[filepath,~,ext] = fileparts(file);
fprintf('Loading...');
load(file);
fprintf('OK.\n');
isDry = contains(folder,'dry','IgnoreCase',true) ||...
    contains(filename,'dry','IgnoreCase',true);
isAir = contains(folder,'air','IgnoreCase',true) ||...
    contains(filename,'air','IgnoreCase',true);
isWet = contains(folder,'wet','IgnoreCase',true) ||...
    contains(filename,'wet','IgnoreCase',true);
isPBS = contains(folder,'pbs','IgnoreCase',true) ||...
    contains(filename,'pbs','IgnoreCase',true);
isDIW = contains(folder,'diw','IgnoreCase',true) ||...
    contains(filename,'diw','IgnoreCase',true);
fprintf('Retrieving environment...');
if isDry || isAir
    isShortRange = false;
    fprintf('DRY.\n');
elseif isWet || isPBS || isDIW
    isShortRange = true;
    fprintf('WET.\n');
else
    fprintf('NOT FOUND.\n');
    isShortRange = input('Enter 0 for dry and 1 for wet: ');
end
fprintf('Retrieving number of channels...');
[~,numOfChannels] = size(structIV);
fprintf('%d.\n',numOfChannels);

% Parameters
fprintf('Retrieving number of cycles...');
voltage_ = structIV(1).Voltage;
current_ = structIV(1).Current;
% currenAt0 = find(current_ == 0);
% voltage_(currenAt0) = [];
% current_(currenAt0) = [];
voltageMin = min(voltage_);
voltageMax = max(voltage_);
voltageStart = voltage_(1);
numOfSteps = length(voltage_);
stepAtVoltageStart = find(voltage_ == voltageStart);
stepAtVoltageStart_len = length(stepAtVoltageStart);
numOfCycles = (stepAtVoltageStart_len - 1) / 2;
fprintf('%d.\n',numOfCycles);
stepAtCycleStart_idx = [];
for step_idx = 1:(stepAtVoltageStart_len-1)
    if rem(step_idx,2) == 1
        stepAtCycleStart_idx_alloc = [stepAtCycleStart_idx,step_idx];
        stepAtCycleStart_idx = stepAtCycleStart_idx_alloc;
    end
end
stepAtCycleStart = stepAtVoltageStart(stepAtCycleStart_idx);
cycleNum_process = 0; %#ok<NASGU>
cycleNum_use = 0;
if numOfCycles == 1
    cycleNum_process = 1;
    cycleNum_use = 1;
else
    cycleNum_process = input('Enter cycle number to process (use 0 for all): ');
    while cycleNum_use == 0
        if cycleNum_process == 0
            cycleNum_use = 1:numOfCycles;
        elseif cycleNum_process > numOfCycles
            fprintf('Wrong input');
        else
            cycleNum_use = cycleNum_process;
        end
    end
end
numOfCycles_use = length(cycleNum_use);
isNotCorrect = input('Enter 1 to correct data, otherwise 0: ');
fprintf('\n');

% Figure
[screenWidth,screenHeight] = getScreenSize();% Screen
figSize = input('Enter 1 to make large figure size, 0 otherwise: ');
if figSize
    figWidth = 960;
    figHeight = 720;
else
    figWidth = 720;
    figHeight = 360;
end
figPosY = screenHeight - figHeight - WINDOW_HEADER;
% Export
saveFig = input('Enter 1 to save figures, 0 otherwise: ');
if saveFig
    name = input('Enter save name: ','s');
    saveFolder = folder;
    % saveFolder = fullfile(folder,'IV');
    % status = mkdir(saveFolder);
end

% Linear regression
channelFail_array = [];
voltageFailure_array = [];
slopeArray = [];
interceptArray = [];
regArray = [];
resArray = [];

%% IV
% Generate plot
% fprintf('Generating I-V plot...\n');
for channelNum = 1:numOfChannels
    channelName = structIV(channelNum).Channel;
    fprintf('Processing %s...',channelName);
    fig = figure('Name',channelName);

    % Plot values
    legendArray = {};
    annot_text_array = {};
    trendline = gobjects(numOfCycles,1);
    for cycleNum = cycleNum_use
        cycleNum_name = sprintf('Cycle %d',cycleNum);
        legendArray_alloc = [legendArray,cycleNum_name];
        legendArray = legendArray_alloc;
        current_all = structIV(channelNum).Current;
        voltage_all = structIV(channelNum).Voltage;
        stepCycleStart = stepAtCycleStart(cycleNum);
        if cycleNum == numOfCycles
            stepCycleEnd = numOfSteps;
        else
            stepCycleEnd = stepAtCycleStart(cycleNum+1);
        end

        if isNotCorrect == true
            numOfChecks = 2;
        else
            numOfChecks = 1;
        end
        for check = 1:numOfChecks
            current = current_all(stepCycleStart:stepCycleEnd);
            voltage = voltage_all(stepCycleStart:stepCycleEnd);
            if check == 2
                voltage_0 = find(voltage == 0);
                current_0 = current(voltage_0);
                offset = mean(current_0);
                current = current - offset;
            end
            %             [current_fix,voltage_fix,~] = getNoOverflow(current,voltage,0);
            current_fix = current;
            voltage_fix = voltage;
            if isShortRange
                %             xPos = find(voltage_fix >= 0);
                %             currentPos = current_fix(xPos);
                %             voltagePos = voltage_fix(xPos);
                %             linReg = polyfit(voltagePos,currentPos,1);
                voltage_fix_abs = abs(voltage_fix);
                position_idx = find(voltage_fix_abs <= 0.5);
                current_fix = current_fix(position_idx);
                voltage_fix = voltage_fix(position_idx);
%                 linReg = polyfit(voltagePos,currentPos,1);
%                 [slope,intercept,reg] = getLinReg(voltagePos,currentPos);
            end
            % trendline
%             slope = linReg(LINREG_SLOPE_IDX);
%             intercept = linReg(LINREG_INTERCEPT_IDX);
            [slope,intercept,reg] = getLinReg(voltage_fix,current_fix);
        end

        % resistance
        res = abs(1 / slope);
        % coefficient of determination
%         linEval_row = polyval(linReg,voltage_fix);
%         num = sum((current_fix - linEval_row).^2);
%         den = sum((current_fix - mean(current_fix)).^2);
%         reg = max(1 - num/den);

        slopeArray_alloc = [slopeArray,slope];
        slopeArray = slopeArray_alloc;
        interceptArray_alloc = [interceptArray,intercept];
        interceptArray = interceptArray_alloc;
        regArray_alloc = [regArray,reg];
        regArray = regArray_alloc;
        resArray_alloc = [resArray,res];
        resArray = resArray_alloc;

        if numOfCycles_use == 1
            %         color = de2bi(1,3);
            color = MATLAB_COLOR{1};
            lineStyle = LINE_STYLE{1};
            marker = MARKER_TYPE{1};
        else
            %         color = de2bi(cycleNum,3);
            color = MATLAB_COLOR{cycleNum};
            lineStyle = LINE_STYLE{cycleNum};
            marker = MARKER_TYPE{cycleNum};
        end
        plot(voltage_fix,current_fix,...
            'Color',color,...
            'LineStyle',lineStyle,...
            'LineWidth',2,...
            'Marker',marker,...
            'MarkerFaceColor',color);
        ax = gca;
        hold on;
        box on;
        set(ax,'LineWidth',2);
%         set(ax,'TickLength',[0.0075 0.025]);
        %         xlim('auto');
        xlim('tickaligned');
        %         ylim('padded');
%                 ylim('tickaligned');
        if voltageMin == -5 && voltageMax == 5
            set(ax,'XMinorTick','on');
        end
        %         xlim([voltageMin,voltageMax]);

        % Annotation
        %         if reg > REG_THRESH
        trend = slope * voltage_fix + intercept;
        trendline(cycleNum) = plot(voltage_fix,trend,'k--',...
            'LineStyle',lineStyle,...
            'LineWidth',1,...
            'HandleVisibility','off');
        %         legendArray_alloc = [legendArray;''];
        %         legendArray = legendArray_alloc;

        resOrderOfMAg = floor(log10(res));
        equation_str = sprintf(...
            '{\\bf{\\ity}} = %.4g{\\bf{\\itx}} + %.4g',...
            slope,intercept);
        reg_str = sprintf(...
            '{\\bf{\\itr}^{2}} = %.4g',...
            reg);
        if resOrderOfMAg >= PETA_MAG
            res_scaled = res * N_TO_PETA;
            res_str = sprintf(...
                '{\\bf{\\itR}} = %.4g {\\bfP\\Omega}',...
                res_scaled);
        elseif resOrderOfMAg >= TERA_MAG
            res_scaled = res * N_TO_TERA;
            res_str = sprintf(...
                '{\\bf{\\itR}} = %.4g {\\bfT\\Omega}',...
                res_scaled);
        elseif resOrderOfMAg >= GIGA_MAG
            res_scaled = res * N_TO_GIGA;
            res_str = sprintf(...
                '{\\bf{\\itR}} = %.4g {\\bfG\\Omega}',...
                res_scaled);
        elseif resOrderOfMAg >= MEGA_MAG
            res_scaled = res * N_TO_MEGA;
            res_str = sprintf(...
                '{\\bf{\\itR}} = %.4g {\\bfM\\Omega}',...
                res_scaled);
        elseif resOrderOfMAg >= KILO_MAG
            res_scaled = res * N_TO_KILO;
            res_str = sprintf(...
                '{\\bf{\\itR}} = %.4g {\\bfk\\Omega}',...
                res_scaled);
        else
            res_str = sprintf(...
                '{\\bf{\\itR}} = %.4g {\\bf\\Omega}',...
                res);
        end

        if numOfCycles_use > 1
            if cycleNum == 1
                annot_text = sprintf('{\\bfCycle %d}\n%s\n%s\n%s',...
                    cycleNum,...
                    equation_str,...
                    reg_str,...
                    res_str);
            else
                try
                    delete(annot);
                catch
                end
                annot_text = sprintf('\n{\\bfCycle %d}\n%s\n%s\n%s',...
                    cycleNum,...
                    equation_str,...
                    reg_str,...
                    res_str);
            end
        else
            annot_text = sprintf('%s\n%s\n%s',...
                equation_str,...
                reg_str,...
                res_str);
        end
        annot_text_array_alloc = [annot_text_array,annot_text];
        annot_text_array = annot_text_array_alloc;
        annot = annotation(...
            fig,...
            'textbox',ANNOT_DIM,...
            'String',annot_text_array_alloc,...
            'FontSize',12,...
            'FitBoxToText','on');
        %         end

        % Labels
        %         ivPlot_title = sprintf(...
        %             'I-V Curve: %+.2f V to %+.2f V',...
        %             voltageMin,voltageMax);
        ivPlot_title = sprintf('I-V Curve');
        title(ivPlot_title);
        subtitle(channelName);
        % axes
        xlabel('Voltage (V)');
        ylabel('Current (A)');
        set(ax,'FontSize',20);
        %         ytickformat('%.2g');

        move = (channelNum-1) * FIG_SHIFT;
        figPosX_new = FIG_POS_X + move;
        figPosY_new = figPosY - move;
        set(fig,'Position',[figPosX_new,figPosY_new,figWidth,figHeight]);
    end
    fprintf('OK.\n');

    if numOfCycles_use > 1
        confirmLegend = 0;
        legend(legendArray,'Location',DEFAULT_POSITION);
        while confirmLegend == false
            defaultPosition_idx = ismember(POSITION_LIST,DEFAULT_POSITION);
            defaultPosition = find(defaultPosition_idx);
            listPrompt = 'Select legend position.';
            [listPosition_idx,listPosition_tf] = listdlg(...
                'ListString',POSITION_LIST,...
                'PromptString',listPrompt,...
                'SelectionMode','single',...
                'InitialValue',defaultPosition,...
                'Name','Legend Position');
            if listPosition_tf == false
                fprintf('\n');
                fprintf('PROGRAM ENDED\n\n');
                return;
            end
            positionSelect = POSITION_LIST{listPosition_idx};
            descriptionSelect = DESCRIPTION_LIST{listPosition_idx};
            legend(legendArray,'Location',positionSelect);

            positionPrompt = sprintf('Selected legend position: {\\bf%s}',positionSelect);
            questPrompt = {positionPrompt,descriptionSelect};
            confirmPosition = questdlg(...
                questPrompt,...
                'Confirm',...
                BUTTON_CONFIRM,BUTTON_TRY,BUTTON_QUIT,...
                opts);

            switch confirmPosition
                case BUTTON_CONFIRM
                    confirmLegend = 1;
                case BUTTON_TRY
                    continue;
                case BUTTON_QUIT
                    fprintf('\n');
                    fprintf('PROGRAM ENDED\n\n');
                    return;
                otherwise
                    fprintf('\n');
                    fprintf('PROGRAM ENDED\n\n');
                    return;
            end
        end
    end

    % Export images
    if saveFig
        if cycleNum_process ~= 0
            filename = sprintf('%s_%s_%s_Cycle%d_annot',name,'IV',channelName,cycleNum_use);
        else
            filename = sprintf('%s_%s_%s_annot',name,'IV',channelName);
        end
        exportImage(fig,filename,saveFolder);
    end

    title('');
    subtitle('');
    try
        delete(trendline);
    catch
    end
    try
        delete(annot);
    catch
    end
    if numOfCycles_use > 1
        confirmLegend = 0;
        while confirmLegend == false
            listPrompt = 'Select legend position.';
            [listPosition_idx,listPosition_tf] = listdlg(...
                'ListString',POSITION_LIST,...
                'PromptString',listPrompt,...
                'SelectionMode','single',...
                'InitialValue',listPosition_idx,...
                'Name','Legend Position');
            if listPosition_tf == false
                fprintf('\n');
                fprintf('PROGRAM ENDED\n\n');
                return;
            end
            positionSelect = POSITION_LIST{listPosition_idx};
            descriptionSelect = DESCRIPTION_LIST{listPosition_idx};
            legend(legendArray,'Location',positionSelect);

            positionPrompt = sprintf('Selected legend position: {\\bf%s}',positionSelect);
            questPrompt = {positionPrompt,descriptionSelect};
            confirmPosition = questdlg(...
                questPrompt,...
                'Confirm',...
                BUTTON_CONFIRM,BUTTON_TRY,BUTTON_QUIT,...
                opts);

            switch confirmPosition
                case BUTTON_CONFIRM
                    confirmLegend = 1;
                case BUTTON_TRY
                    continue;
                case BUTTON_QUIT
                    fprintf('\n');
                    fprintf('PROGRAM ENDED\n\n');
                    return;
                otherwise
                    fprintf('\n');
                    fprintf('PROGRAM ENDED\n\n');
                    return;
            end
        end
    end
    drawnow;
    %     if numOfCycles_use > 1
    %         legend(legendArray,'location','best');
    %     end
    if saveFig
        if cycleNum_process ~= 0
            filename = sprintf('%s_%s_%s_Cycle%d',name,'IV',channelName,cycleNum_use);
        else
            filename = sprintf('%s_%s_%s',name,'IV',channelName);
        end
        exportImage(fig,filename,saveFolder);
        fprintf('\n');
    end
end
stats = [slopeArray;interceptArray;regArray;resArray];

%% Program End
fprintf('PROGRAM ENDED\n\n');

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