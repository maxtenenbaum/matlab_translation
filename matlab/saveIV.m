%% Saving data
function [iv_mat,iv_xlsx] = saveIV(...
    subjectName,...
    lowerLimit,...
    upperLimit,...
    channelSelect_len,...
    channelNameList,...
    savePath,...
    structIV)
%% Constants
% Values
% DIR_ERR_ID = 'MATLAB:save:noParentDir';
YES = 1;
ZERO = 0;
TWO = 2;
ONE = 1;
FIRST = 1;
% Outputs
SAVE_FOLDER = 'IV';
CHANNEL_TABLE_HEADING = {...    % heading
    'Voltage Step (V)',...      % voltage
    'Current (A)',...           % leakage current
    'Start Date and Time',...   % end date and time
    'End Date and Time'};       % end date and time

%% Variables
[structIV_name] = getVarName(structIV);
data = structIV(FIRST).Voltage;  	% time data array
[~,numOfRepeats] = size(data);
if numOfRepeats > ONE
    data_len = length(data(FIRST));
else
    data_len = length(data);
end
current_mat = zeros(data_len,channelSelect_len);

%% Function
fprintf('Saving IV data...\n');

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
        experiment_char = 'IV';
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
        iv_mat = fullfile(savePath,SAVE_FOLDER,filename_mat);   % save path for .mat file
%         count = TWO;
%         while exist(iv_mat,'file')
%             count_char = sprintf('_%d',count);
%             filename_mat = append(filename_char,count_char,'.mat'); % filename for .mat file
%             iv_mat = fullfile(savePath,SAVE_FOLDER,filename_mat);   % save path for .mat file
%             count = count + ONE;
%         end
        save(iv_mat);           % save .mat file
%         removeFig(filename_mat_save);
        fprintf('%s\n',filename_mat);                       % .mat file saved
        
        % Making spreadsheet files
        if numOfRepeats == ONE
            filename_xlsx = append(filename_char,'.xlsx');          % filename for .xlsx file
            iv_xlsx = fullfile(savePath,SAVE_FOLDER,filename_xlsx); % save path for .xlsx file

            % All
            allTableHeading = {'Voltage Step (V)'};  % voltage
            for channel_idx = FIRST:channelSelect_len
                channelName_char = channelNameList(channel_idx);
                channelName = sprintf('%s (A)',channelName_char);
                allTableHeading{end+ONE} = channelName;
                % capture data of channel
                voltage_data = structIV(channel_idx).Voltage;  	% voltage data array
                current_data = structIV(channel_idx).Current;% leakage current array
                current_mat(:,channel_idx) = current_data;% leakage current matrix
            end

            % data table
            compiledMat = [voltage_data,current_mat];
            compiledTable = array2table(...                             % table
                compiledMat,...          	
                'VariableNames',allTableHeading);
            writetable(compiledTable,iv_xlsx,'Sheet','ALL'); % save sheet to .xlsx file

            % Channel
            for channel_idx = FIRST:channelSelect_len
                channelName_char = channelNameList(channel_idx);
                % capture data of channel
                voltage_data_raw = structIV(channel_idx).Voltage;  	% voltage data array
                voltage_data = zeros(data_len,ONE);
                voltage_data(:) = voltage_data_raw(:);  
                current_data_raw = structIV(channel_idx).Current;   % 
                current_data = zeros(data_len,ONE);
                current_data(:) = current_data_raw(:);                 % current data array
                dateTimeStart_point = structIV(channel_idx).DateTimeStart;
                dateTimeEnd_point = structIV(channel_idx).DateTimeEnd;  	% date and time completed

                % data table
                stringArray = strings(data_len,ONE);
                dateTimeStart_data = stringArray;
                dateTimeStart_data(FIRST) = dateTimeStart_point;
                dateTimeEnd_data = stringArray;
                dateTimeEnd_data(FIRST) = dateTimeEnd_point;
                compiledTable = table(...          	% table
                    voltage_data,...          	% voltage
                    current_data,...     	% leakage current
                    dateTimeStart_data,...          % start date and time
                    dateTimeEnd_data,...            % end date and time
                    'VariableNames',CHANNEL_TABLE_HEADING);  

            %     % Make filename for .csv file
            %     filename_csv_char = sprintf('%s_%s.csv',filename_char,channelName_char);% filename for .csv file (char)
            %     filename_csv = convertCharsToStrings(filename_csv_char);            	% filename string for .csv file (string)
            %     filename_csv_save = fullfile(savePath,filename_csv);               	% save path for .csv file

                % Save spreadsheets
            %     writetable(tableData,filename_csv_save);                          % save .csv file
            %     fprintf('%s\n',filename_csv);                                     % .csv file saved

                writetable(compiledTable,iv_xlsx,'Sheet',channelName_char);  % save sheet to .xlsx file
            end
            fprintf('%s\n',filename_xlsx);	% .xlsx file saved
    %         fprintf('All files saved.\n');% all spreadsheet files saved
    %         errFound = 0;
        else
            iv_xlsx = 0;
        end
%     catch
%     end
% end
        
end