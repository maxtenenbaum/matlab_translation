%% Saving data
function [filepath_mat,filepath_xlsx,filepath_tif] = saveIT2(File,itPlot)
%% Constants
% Values
% DIR_ERR_ID = 'MATLAB:save:noParentDir';
% FILE_OPEN_ERR_ID = 'MATLAB:invalidType';
% Output
CHANNEL_TABLE_HEADING = {...            % heading
    'Time (s)',...              % time
    'Current (A)',...           % leakage current
    'Start Date and Time',...   % end date and time
    'End Date and Time'};       % end date and time

%% Variables
expID = File.Experiment.ID;
isCheckConstant = contains2(expID,'IT');
notebook = File.Notebook;
subjectName = File.Subject;
channelSelect = File.Experiment.Channels.Number;
channelNameList = File.Experiment.Channels.Name;
channelSelect_len = length(channelSelect);
savePath = File.Path;
numOfSteps = File.Experiment.Parameters.NumberOfSteps;
File.Instrument.Object = [];

if ~isCheckConstant
    stepNum = length(File.StepData);
    voltageBias = File.StepData(stepNum).VoltageBias;
    Data = File.StepData.Data;
else
    voltageBias = File.Experiment.Parameters.VoltageBias;
    Data = File.Data;
end
filepath_mat = [];
filepath_xlsx = [];
filepath_tif = [];
% [structIT_name] = getVarName(Data);
data = Data(1).Time;  	% time data array
% [numOfRepeats,~] = size(data);
% if numOfRepeats > 1
%     data_len = length(data(1));
% else
data_len = length(data);
% end
current_mat = zeros(data_len,channelSelect_len);

%% Function
fprintf('Saving IT data...\n');
try
    folderPath = fullfile(savePath,'IT');
    mkdir(folderPath);
catch
end

% Starting filename
subjectName_char = sprintf('%s_%s',notebook,subjectName);
if voltageBias == 0
    voltageBias_char = sprintf('%05.2fV',voltageBias);
else
    voltageBias_char = sprintf('%+05.2fV',voltageBias);
end
% hasPlus = contains(voltageBias_char,'+');
% if hasPlus == true
%     voltageBias_char = strrep(voltageBias_char,'+','pos');
% end
% hasMinus = contains(voltageBias_char,'-');
% if hasMinus == true
%     voltageBias_char = strrep(voltageBias_char,'-','neg');
% end
logNumOfSteps = log10(numOfSteps);
numOfDigits = floor(logNumOfSteps) + 1;
if numOfSteps == 0 || numOfDigits == 0
    filename_char = append(...
        subjectName_char,'_',...
        'IT','_',...
        voltageBias_char);
else
    switch numOfDigits
        case 1
            stepNum_char = sprintf('Step%01d',stepNum);
        case 2
            stepNum_char = sprintf('Step%02d',stepNum);
        case 3
            stepNum_char = sprintf('Step%03d',stepNum);
        case 4
            stepNum_char = sprintf('Step%04d',stepNum);
    end
    filename_char = append(...
        subjectName_char,'_',....
        expID,'_',...
        stepNum_char,'_',...
        voltageBias_char);
end

% Making .mat file
if isCheckConstant
    startTime = tic;
    filename_mat = [filename_char '.mat'];            % filename for .mat file
    filepath_mat = fullfile(savePath,'IT',filename_mat);   % save path for .mat file
    % count = 2;
    % while exist(ct_mat,'file')
    %     count_char = sprintf('_%d',count);
    %     filename_mat = append(filename_char,count_char,'.mat');       	% filename for .mat file
    %     ct_mat = fullfile(savePath,'IT',filename_mat);  % save path for .mat file
    %     count = count + 1;
    % end
    save(filepath_mat);               % save .mat file
    %         removeFig(filename_mat_save);
    [endTime,unit] = getEndTime(startTime);
    fprintf('\t%s (%.2f %s)\n',filename_mat,endTime,unit);                         % .mat file saved
end

% Making spreadsheet files
startTime = tic;
if isCheckConstant
    %         if numOfRepeats == 1
    filename_xlsx = [filename_char '.xlsx'];    	% filename for .xlsx file
    filepath_xlsx = fullfile(savePath,'IT',filename_xlsx);% save path for .xlsx file

    % All
    allTableHeading = {'Time (s)'};  % time
    for channel_idx = 1:channelSelect_len
        channelName_char = channelNameList(channel_idx);
        channelName = sprintf('%s (A)',channelName_char);
        %     allTableHeading{end+1} = channelName;
        allTableHeading_alloc = [allTableHeading,channelName];
        allTableHeading = allTableHeading_alloc;
        % capture data of channel
        time_data_raw = Data(channel_idx).Time;
        time_data = zeros(data_len,1);
        time_data(:) = time_data_raw(:);                       % time data array

        %     current_data_raw = Data(channel_idx).Current;
        %     current_data = zeros(data_len,1);
        %     current_data(:) = current_data_raw(:);                 % current data array
        current_data = Data(channel_idx).Current;
        current_mat(:,channel_idx) = current_data;          % leakage current matrix
    end

    % data table
    compiledMat = [time_data,current_mat];
    compiledTable = array2table(...                             % table
        compiledMat,...
        'VariableNames',allTableHeading);
    writetable(compiledTable,filepath_xlsx,'Sheet','ALL'); % save sheet to .xlsx fil
end
for channel_idx = 1:channelSelect_len
%     startChannelTime = tic;
    channelName_char = channelNameList(channel_idx);
    % Capture data of channel
    time_data_raw = Data(channel_idx).Time;
    time_data = zeros(data_len,1);
    time_data(:) = time_data_raw(:);                       % time data array
    current_data_raw = Data(channel_idx).Current;
    current_data = zeros(data_len,1);
    current_data(:) = current_data_raw(:);                 % current data array
    dateTimeStart_point = Data(channel_idx).DateTimeStart;
    dateTimeEnd_point = Data(channel_idx).DateTimeEnd;     	% date and time completed

    % Data table
    dataLength = length(time_data);
    stringArray = strings(dataLength,1);
    dateTimeStart_data = stringArray;
    dateTimeStart_data(1,:) = dateTimeStart_point;
    dateTimeEnd_data = stringArray;
    dateTimeEnd_data(1) = dateTimeEnd_point;
    tableData = table(...               % table
        time_data,...                   % time
        current_data,...     	% leakage current
        dateTimeStart_data,...          % start date and time
        dateTimeEnd_data,...            % end date and time
        'VariableNames',CHANNEL_TABLE_HEADING);

    % Save spreadsheets
    if isCheckConstant
        writetable(tableData,filepath_xlsx,'Sheet',channelName_char);  % save sheet to .xlsx file
%     else
%         [endChannelTime,unit] = getEndTime(startChannelTime);
%         filename_csv = sprintf('%s_%s.csv',filename_char,channelName_char);% filename for .csv file
%         filename_csv_save = fullfile(savePath,filename_csv);               	% save path for .csv file
%         writetable(tableData,filename_csv_save);                            % save .csv file
%         fprintf('\t%s (%.2f %s)\n',filename_csv,endChannelTime,unit);       % .csv file saved
    end
end
if isCheckConstant
    [endTime,unit] = getEndTime(startTime);
    fprintf('\t%s (%.2f %s)\n',filename_xlsx,endTime,unit);	% .xlsx file saved
end
% end

% Figure
if ~isempty(itPlot)
    startTime = tic;
    filename_tif = append(filename_char,'.tif');
    filepath_tif = fullfile(savePath,'IT',filename_tif);
    % count = 2;
    % while exist(filename_tif,'file')
    %     count_char = sprintf('_%d',count);
    %     filename_fig = append(filename_char,count_char,'.tif');
    %     filename_tif = fullfile(savePath,'IT',filename_fig);
    %     count = count + 1;
    % end
    print(itPlot,'-dtiffn',filepath_tif);
    [endTime,unit] = getEndTime(startTime);
    fprintf('\t%s (%.2f %s)\n',filename_tif,endTime,unit);
end
% end

% fprintf('All files saved.\n');  % all spreadsheet files saved

end