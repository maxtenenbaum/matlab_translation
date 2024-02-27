%% Saving data
function [filepath_mat,filepath_xlsx,filepath_tif_cell] = saveIV2(File,ivFig_arr)
%% Constants
% Values
% Outputs
SAVE_FOLDER = 'IV';
CHANNEL_TABLE_HEADING = {...    % heading
    'Voltage Step (V)',...      % voltage
    'Current (A)',...           % leakage current
    'Start Date and Time',...   % end date and time
    'End Date and Time'};       % end date and time

%% Variables
expID = File.Experiment.ID;
notebook = File.Notebook;
subjectName = File.Subject;
channelSelect = File.Experiment.Channels.Number;
channelNameList = File.Experiment.Channels.Name;
channelSelect_len = length(channelSelect);
numOfSteps = File.Experiment.Parameters.NumberOfSteps;
savePath = File.Path;
File.Instrument.Object = [];

if strcmpi(expID,'STEP')
    lowerLimit = File.Experiment.Parameters.StartingVoltage;
    upperLimit = File.Experiment.Parameters.EndingVoltage;
else
    lowerLimit = File.Experiment.Parameters.LowerLimit;
    upperLimit = File.Experiment.Parameters.UpperLimit;
end

voltage_data = File.Data(1).Voltage;  	% time data array
current_mat = zeros(numOfSteps,channelSelect_len);

%% Function
fprintf('Saving IV data...\n');

folderPath = fullfile(savePath,expID);
mkdir(folderPath);
% Starting filename
subjectName_char = sprintf('%s_%s',notebook,subjectName);
if lowerLimit == 0 && upperLimit == 0
    limits_char = sprintf('%05.2fV_%05.2fV',lowerLimit,upperLimit);
elseif lowerLimit == 0
    limits_char = sprintf('%05.2fV_%+05.2fV',lowerLimit,upperLimit);
elseif upperLimit == 0
    limits_char = sprintf('%+05.2fV_%05.2fV',lowerLimit,upperLimit);
else
    limits_char = sprintf('%+05.2fV_%+05.2fV',lowerLimit,upperLimit);
end
% hasPlus = contains(limits_char,'+');
% if hasPlus == true
%     limits_char = strrep(limits_char,'+','pos');
% end
% hasMinus = contains(limits_char,'-');
% if hasMinus == true
%     limits_char = strrep(limits_char,'-','neg');
% end
filename_char = append(...
    subjectName_char,'_',...
    expID,'_',...
    limits_char);

% Making .mat file
startTime = tic;
filename_mat = append(filename_char,'.mat');            % filename for .mat file
filepath_mat = fullfile(savePath,SAVE_FOLDER,filename_mat);   % save path for .mat file
File_name = getVarName(File);
save(filename_mat,File_name);           % save .mat file
[endTime,unit] = getEndTime(startTime);
fprintf('\t%s (%.2f %s)\n',filename_mat,endTime,unit);                       % .mat file saved

% Making spreadsheet files
startTime = tic;
filename_xlsx = append(filename_char,'.xlsx');          % filename for .xlsx file
filepath_xlsx = fullfile(savePath,SAVE_FOLDER,filename_xlsx); % save path for .xlsx file

% All
allTableHeading = {'Voltage Step (V)'};  % voltage
for channel_idx = 1:channelSelect_len
    channelName_char = channelNameList(channel_idx);
    channelName = sprintf('%s (A)',channelName_char);
%     allTableHeading{end+1} = channelName;
    allTableHeading_alloc = [allTableHeading,channelName];
    allTableHeading = allTableHeading_alloc;
    % capture data of channel
    current_data = File.Data(channel_idx).Current;% leakage current array
    current_mat(:,channel_idx) = current_data;% leakage current matrix
end

% data table
compiledMat = [voltage_data,current_mat];
compiledTable = array2table(...                             % table
    compiledMat,...
    'VariableNames',allTableHeading);
writetable(compiledTable,filepath_xlsx,'Sheet','ALL'); % save sheet to .xlsx file

% Channel
for channel_idx = 1:channelSelect_len
    channelName_char = channelNameList(channel_idx);
    % capture data of channel
    voltage_data_raw = File.Data(channel_idx).Voltage;  	% voltage data array
    voltage_data = zeros(numOfSteps,1);
    voltage_data(:) = voltage_data_raw(:);
    current_data_raw = File.Data(channel_idx).Current;   %
    current_data = zeros(numOfSteps,1);
    current_data(:) = current_data_raw(:);                 % current data array
    dateTimeStart_point = File.Data(channel_idx).DateTimeStart;
    dateTimeEnd_point = File.Data(channel_idx).DateTimeEnd;  	% date and time completed

    % data table
    stringArray = strings(numOfSteps,1);
    dateTimeStart_data = stringArray;
    dateTimeStart_data(1) = dateTimeStart_point;
    dateTimeEnd_data = stringArray;
    dateTimeEnd_data(1) = dateTimeEnd_point;
    compiledTable = table(...          	% table
        voltage_data,...          	% voltage
        current_data,...     	% leakage current
        dateTimeStart_data,...          % start date and time
        dateTimeEnd_data,...            % end date and time
        'VariableNames',CHANNEL_TABLE_HEADING);
    writetable(compiledTable,filepath_xlsx,'Sheet',channelName_char);  % save sheet to .xlsx file
end
[endTime,unit] = getEndTime(startTime);
fprintf('\t%s (%.2f %s)\n',filename_xlsx,endTime,unit);	% .xlsx file saved

% Figure
if ~isempty(ivFig_arr)
    filepath_tif_cell = cell(1,channelSelect_len);
    for channel_idx = 1:channelSelect_len
        startTime = tic;
        ivPlot = ivFig_arr(channel_idx);
        channelName_char = channelNameList(channel_idx);
        filename_channel_char = sprintf('%s_%s',filename_char,channelName_char);% filename for .tif file (char)
        filename_tif = append(filename_channel_char,'.tif');
        filepath_tif = fullfile(savePath,SAVE_FOLDER,filename_tif);
        print(ivPlot,'-dtiffn',filepath_tif);
        filepath_tif_cell{channel_idx} = filepath_tif;
        [endTime,unit] = getEndTime(startTime);
        fprintf('\t%s (%.2f %s)\n',filename_tif,endTime,unit);
    end
end

% fprintf('All files saved.\n');% all spreadsheet files saved

end