%% Saving data
function [ct_mat,ct_xlsx] = saveCT(...
    subjectName,...
    numOfSteps,...
    stepNum,...
    voltageBias,...
    channelSelect_len,...
    channelNameList,...
    savePath,...
    structCT)
%% Constants
% Values
% DIR_ERR_ID = 'MATLAB:save:noParentDir';
% FILE_OPEN_ERR_ID = 'MATLAB:invalidType';
ZERO = 0;
ONE = 1;
TWO = 2;
FIRST = 1;
% Output
SAVE_FOLDER = 'CT';
CHANNEL_TABLE_HEADING = {...            % heading
    'Time (s)',...              % time
    'Current (A)',...           % leakage current
    'Start Date and Time',...   % end date and time
    'End Date and Time'};       % end date and time

%% Variables
ct_xlsx = [];
[structCT_name] = getVarName(structCT);
data = structCT(FIRST).Time;  	% time data array
% [numOfRepeats,~] = size(data);
% if numOfRepeats > ONE
%     data_len = length(data(FIRST));
% else
data_len = length(data);
% end
current_mat = zeros(data_len,channelSelect_len);

%% Function
fprintf('Saving CT data...\n');

try
    folderPath = fullfile(savePath,SAVE_FOLDER);
    status = mkdir(folderPath);
catch
end

% errFound = 1;
% while errFound == YES
%     try
% Starting filename
subjectName_char = sprintf('%s',subjectName);
experiment_char = 'CT';
if voltageBias == ZERO
    voltageBias_char = sprintf('%05.2fV',voltageBias);
else
    voltageBias_char = sprintf('%+05.2fV',voltageBias);
end
hasPlus = contains(voltageBias_char,'+');
if hasPlus == true
    voltageBias_char = strrep(voltageBias_char,'+','pos');
end
hasMinus = contains(voltageBias_char,'-');
if hasMinus == true
    voltageBias_char = strrep(voltageBias_char,'-','neg');
end
logNumOfSteps = log10(numOfSteps);
numOfDigits = floor(logNumOfSteps) + 1;
if numOfSteps == 0 || numOfDigits == 0
    filename_char = append(...
        subjectName_char,'_',...
        experiment_char,'_',...
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
        experiment_char,'_',...
        stepNum_char,'_',...
        voltageBias_char);
end

% Making .mat file
filename_mat = append(filename_char,'.mat');            % filename for .mat file
ct_mat = fullfile(savePath,SAVE_FOLDER,filename_mat);   % save path for .mat file
count = TWO;
while exist(ct_mat,'file')
    count_char = sprintf('_%d',count);
    filename_mat = append(filename_char,count_char,'.mat');       	% filename for .mat file
    ct_mat = fullfile(savePath,SAVE_FOLDER,filename_mat);  % save path for .mat file
    count = count + ONE;
end
save(ct_mat);               % save .mat file
%         removeFig(filename_mat_save);
fprintf('%s\n',filename_mat);                         % .mat file saved

% Making spreadsheet files
if data_len < 2^20
    %         if numOfRepeats == ONE
    filename_xlsx = append(filename_char,'.xlsx');    	% filename for .xlsx file
    filename_xlsx_save = fullfile(savePath,SAVE_FOLDER,filename_xlsx);% save path for .xlsx file
    ct_save_alloc = [ct_xlsx;filename_xlsx_save];
    ct_xlsx = ct_save_alloc;

    % All
    allTableHeading = {'Time (s)'};  % time
    for channel_idx = FIRST:channelSelect_len
        channelName_char = channelNameList(channel_idx);
        channelName = sprintf('%s (A)',channelName_char);
        allTableHeading{end+ONE} = channelName;
        % capture data of channel
        time_data_raw = structCT(channel_idx).Time;
        time_data = zeros(data_len,ONE);
        time_data(:) = time_data_raw(:);                       % time data array

        current_data_raw = structCT(channel_idx).Current;
        current_data = zeros(data_len,ONE);
        current_data(:) = current_data_raw(:);                 % current data array
        current_mat(:,channel_idx) = current_data;          % leakage current matrix
    end

    % data table
    compiledMat = [time_data,current_mat];
    compiledTable = array2table(...                             % table
        compiledMat,...
        'VariableNames',allTableHeading);
    writetable(compiledTable,filename_xlsx_save,'Sheet','ALL'); % save sheet to .xlsx fil

    for channel_idx = FIRST:channelSelect_len
        channelName_char = channelNameList(channel_idx);
        % Capture data of channel
        time_data_raw = structCT(channel_idx).Time;
        time_data = zeros(data_len,ONE);
        time_data(:) = time_data_raw(:);                       % time data array
        current_data_raw = structCT(channel_idx).Current;
        current_data = zeros(data_len,ONE);
        current_data(:) = current_data_raw(:);                 % current data array
        dateTimeStart_point = structCT(channel_idx).DateTimeStart;
        dateTimeEnd_point = structCT(channel_idx).DateTimeEnd;     	% date and time completed

        % Data table
        dataLength = length(time_data);
        stringArray = strings(dataLength,ONE);
        dateTimeStart_data = stringArray;
        dateTimeStart_data(FIRST) = dateTimeStart_point;
        dateTimeEnd_data = stringArray;
        dateTimeEnd_data(FIRST) = dateTimeEnd_point;
        tableData = table(...               % table
            time_data,...                   % time
            current_data,...     	% leakage current
            dateTimeStart_data,...          % start date and time
            dateTimeEnd_data,...            % end date and time
            'VariableNames',CHANNEL_TABLE_HEADING);

        %     % Make filename for .csv file
        %     filename_csv_char = sprintf('%s_%s.csv',filename_char,channelName_char);% filename for .csv file (char)
        %     filename_csv = convertCharsToStrings(filename_csv_char);            	% filename string for .csv file (string)
        %     filename_csv_save = fullfile(savePath,filename_csv);               	% save path for .csv file

        % Save spreadsheets
        %     writetable(tableData,filename_csv_save);                            % save .csv file
        %     fprintf('%s\n',filename_csv);                                       % .csv file saved
        writetable(tableData,filename_xlsx_save,'Sheet',channelName_char);  % save sheet to .xlsx file
    end
    fprintf('%s\n',filename_xlsx);	% .xlsx file saved
    fprintf('All files saved.\n');  % all spreadsheet files saved
end
%         end
%         errFound = 0;
%     catch
%     end
% end

end