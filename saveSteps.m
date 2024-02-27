%% Saving data
function [steps_mat,steps_xlsx] = saveSteps(...
    subjectName,...
    lowerLimit,...
    upperLimit,...
    channelSelect_len,...
    channelNameList,...
    savePath,...
    structSteps)
%% Constants
% Values
% DIR_ERR_ID = 'MATLAB:save:noParentDir';
YES = 1;
ZERO = 0;
ONE = 1;
TWO = 2;
THREE = 3;
FOUR = 4;
FIRST = 1;
% Outputs
SAVE_FOLDER = 'Steps';
TABLE_HEADING = {...            % heading
    'Time (s)',...              % time
    'Voltage (V)',...           % voltage
    'Current (A)',...           % current
    'Start Date and Time',...   % end date and time
    'End Date and Time'};       % end date and time

%% Variables
[structSteps_name] = getVarName(structSteps);
data = structSteps(FIRST).Voltage;  	% time data array
data_len = length(data);
% [numOfRepeats,~] = size(data);

%% Function
fprintf('Saving Steps data...\n');

try
    folderPath = fullfile(savePath,SAVE_FOLDER);
    status = mkdir(folderPath);
catch
end

errFound = 1;
% while errFound == YES
%     try
        % Starting filename
        subjectName_char = sprintf('%s',subjectName);
        experiment_char = 'Steps';
        if lowerLimit == ZERO && upperLimit == ZERO
            limits_char = sprintf('%05.2fV_%05.2fV',lowerLimit,upperLimit);
        elseif lowerLimit == ZERO
            limits_char = sprintf('%05.2fV_%+05.2fV',lowerLimit,upperLimit);
        elseif upperLimit == ZERO
            limits_char = sprintf('%+05.2fV_%05.2fV',lowerLimit,upperLimit);
        else
            limits_char = sprintf('%+05.2fV_%+05.2fV',lowerLimit,upperLimit);
        end
        hasPlus = contains(limits_char,'+');
        if hasPlus == true
            limits_char = strrep(limits_char,'+','pos');
        end
        hasMinus = contains(limits_char,'-');
        if hasMinus == true
            limits_char = strrep(limits_char,'-','neg');
        end
        filename_char = append(...
            subjectName_char,'_',...
            experiment_char,'_',...
            limits_char);

        % Making .mat file
        filename_mat = append(filename_char,'.mat');            % filename for .mat file
        steps_mat = fullfile(savePath,SAVE_FOLDER,filename_mat);% save path for .mat file
        count = TWO;
        while exist(steps_mat,'file')
            count_char = sprintf('_%d',count);
            filename_mat = append(filename_char,count_char,'.mat'); % filename for .mat file
            steps_mat = fullfile(savePath,SAVE_FOLDER,filename_mat);% save path for .mat file
            count = count + ONE;
        end
        save(steps_mat);                       % save .mat file
        fprintf('%s\n',filename_mat);                           % .mat file saved
        
        % Making spreadsheet files
%         if numOfRepeats == ONE
            filename_xlsx = append(filename_char,'.xlsx');    	% filename for .xlsx file
            steps_xlsx = fullfile(savePath,SAVE_FOLDER,filename_xlsx);% save path for .xlsx file

            for channel_idx = FIRST:channelSelect_len
                channelName_char = channelNameList(channel_idx);

                % Capture data of channel
                time_data_raw = structSteps(channel_idx).Time;
                time_data = zeros(data_len,ONE);
                time_data(:) = time_data_raw(:);                       % time data array
                
                voltage_data_raw = structSteps(channel_idx).Voltage;  	% voltage data array
                voltage_data = zeros(data_len,ONE);
                voltage_data(:) = voltage_data_raw(:); 
                
                current_data_raw = structSteps(channel_idx).Current;
                current_data = zeros(data_len,ONE);
                current_data(:) = current_data_raw(:);                 % current data array
                
                dateTimeStart_point = structSteps(channel_idx).DateTimeStart;
                dateTimeEnd_point = structSteps(channel_idx).DateTimeEnd;  	% date and time completed

                % Data table
                stringArray = strings(data_len,ONE);
                dateTimeStart_data = stringArray;
                dateTimeStart_data(FIRST) = dateTimeStart_point;
                dateTimeEnd_data = stringArray;
                dateTimeEnd_data(FIRST) = dateTimeEnd_point;
                tableData = table(...               % table
                    time_data,...                   % time
                    voltage_data,...                % voltage
                    current_data,...                % current
                    dateTimeStart_data,...          % start date and time
                    dateTimeEnd_data,...            % end date and time
                    'VariableNames',TABLE_HEADING);  

            %     % Make filename for .csv file
            %     filename_csv_char = sprintf('%s_%s.csv',filename_char,channelName_char);% filename for .csv file (char)
            %     filename_csv = convertCharsToStrings(filename_csv_char);            	% filename string for .csv file (string)
            %     filename_csv_save = fullfile(savePath,filename_csv);               	% save path for .csv file

                % Save spreadsheets
            %     writetable(tableData,filename_csv_save);                          % save .csv file
            %     fprintf('%s\n',filename_csv);                                     % .csv file saved
                writetable(tableData,steps_xlsx,'Sheet',channelName_char);  % save sheet to .xlsx file
            end
            fprintf('%s\n',filename_xlsx);	% .xlsx file saved
    %         fprintf('All files saved.\n');% all spreadsheet files saved
%         end
%         errFound = 0;
%     catch
%     end
% end

end