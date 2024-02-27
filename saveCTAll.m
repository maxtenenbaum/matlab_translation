%% Saving data
function [ctAll_mat,ctAll_xlsx] = saveCTAll(...
    subjectName,...
    stepNum,...
    voltageBias,...
    channel_idx,...
    channelNameList,...
    savePath,...
    structCT_All)
%% Constants
% Values
% DIR_ERR_ID = 'MATLAB:save:noParentDir';
YES = 1;
ZERO = 0;
ONE = 1;
FIRST = 1;
% Output
SAVE_FOLDER = 'CT_All';
TABLE_HEADING = {...            % heading
    'Time (s)',...              % time
    'Current (A)',...           % leakage current
    'Start Date and Time',...   % end date and time
    'End Date and Time'};       % end date and time

%% Variables
ctAll_mat = [];
ctAll_xlsx = [];
[structCT_All_name] = getVarName(structCT_All);
data = structCT_All(FIRST).Time;  	% time data array
data_len = length(data);
% [~,numOfRepeats] = size(data);

%% Function
fprintf('Saving compiled CT data...\n');

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
        channelName_char = channelNameList(channel_idx);
        stepNum_char = sprintf('Step%02d',stepNum);
        if voltageBias == ZERO
            voltageBias_char = sprintf('%05.2fV',voltageBias);
        else
            voltageBias_char = sprintf('%+05.2fV',voltageBias);
        end
        filename_char = append(...
            subjectName_char,'_',...
            experiment_char,'_',...
            channelName_char);

        % Making .mat file
        filename_mat = append(filename_char,'.mat');       	% filename for .mat file
        filename_mat_save = fullfile(savePath,SAVE_FOLDER,filename_mat);% save path for .mat file
        save(filename_mat_save);           % save .mat file
%         removeFig(filename_mat_save);
        ctAll_mat_alloc = [ctAll_mat;filename_mat_save];
        ctAll_mat = ctAll_mat_alloc;
        fprintf('%s\n',filename_mat);                       % .mat file saved

        % Making spreadsheet files
%         if numOfRepeats == ONE
            filename_xlsx = append(filename_char,'.xlsx');          % filename for .xlsx file
            filename_xlsx_save = fullfile(savePath,SAVE_FOLDER,filename_xlsx);  % save path for .xlsx file
            ctAll_xlsx_alloc = [ctAll_xlsx;filename_xlsx_save];
            ctAll_xlsx = ctAll_xlsx_alloc;

            % Capture data of channel
            time_data_raw = structCT_All(stepNum).Time;
            time_data = zeros(data_len,ONE);
            time_data(:) = time_data_raw(:);                       % time data array
            current_data_raw = structCT_All(stepNum).Current;
            current_data = zeros(data_len,ONE);
            current_data(:) = current_data_raw(:);                 % current data array
            dateTimeStart_point = structCT_All(stepNum).DateTimeStart;
            dateTimeEnd_point = structCT_All(stepNum).DateTimeEnd;         % date and time completed

            % Data table
            stringArray = strings(data_len,ONE);
            dateTimeStart_data = stringArray;
            dateTimeStart_data(FIRST) = dateTimeStart_point;
            dateTimeEnd_data = stringArray;
            dateTimeEnd_data(FIRST) = dateTimeEnd_point;
            tableData = table(...               % table
                time_data,...                   % time
                current_data,...     	% leakage current
                dateTimeStart_data,...          % start date and time
                dateTimeEnd_data,...            % end date and time
                'VariableNames',TABLE_HEADING);  

            % Save spreadsheets
            sheetName = sprintf('%s_%s',stepNum_char,voltageBias_char);
            writetable(tableData,filename_xlsx_save,'Sheet',sheetName);  % save sheet to .xlsx file

            fprintf('%s\n',filename_xlsx);	% .xlsx file saved
    %             fprintf('All files saved.\n\n');% all spreadsheet files saved
%         end
%         errFound = 0;
%     catch
%     end
% end

end