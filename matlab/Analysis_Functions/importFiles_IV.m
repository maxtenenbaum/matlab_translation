function [File,isQuit] = importFiles_IV(File)
%% Constants
% Button
BUTTON_DONE = 'Done';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
BUTTON_QUIT = 'Quit';
% Options
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
isQuit = false;
retrieving = true;
confirmFile = false;
filename_cell = {};
numOfFilesTotal = 0;
sampleCount = 0;

%% Import Files
fprintf('Retrieving files...\n');
while retrieving
    filesInUse_cell = {};
    while ~confirmFile
        confirmFile = false;
        [SelectedFiles,~] = getFiles('mat',false);
        if isempty(SelectedFiles)
            fprintf('Checking...');
            opts.Default = BUTTON_DONE;
            check_quest = questdlg(...
                '{\bfNo files selected.}', ...
                'Checking',...
                BUTTON_DONE,BUTTON_TRY,BUTTON_QUIT,...
                opts);
            switch check_quest                  	% apply choice
                case BUTTON_DONE                 	% check confirmation
                    fprintf('DONE...');
                    retrieving = false;
                    confirmFile = true;
                    fprintf('OK\n');
                    break;
                case BUTTON_TRY                     % try again
                    fprintf('Trying again...\n');   % starting over
                case BUTTON_QUIT                    % quit
                    fprintf('Quitting...\n\n');  	% quitting
                    return;                         % exit program
                otherwise                           % cancel
                    fprintf('Quitting...\n\n'); 	% quitting
                    return;                         % exit program
            end
        else
            path = SelectedFiles(1).folder;
            numOfFiles = length(SelectedFiles);

            for fileNum = 1:numOfFiles
                filename = SelectedFiles(fileNum).name;
                isAlreadyInUse = contains2(filesInUse_cell,filename);
                if isAlreadyInUse
                    opts.Default = BUTTON_DONE;
                    check_quest = questdlg(...
                        'File already added.', ...
                        'Checking',...
                        BUTTON_DONE,BUTTON_TRY,BUTTON_QUIT,...
                        opts);
                    switch check_quest                  	% apply choice
                        case BUTTON_DONE                 	% check confirmation
                            break;                          % done
                        case BUTTON_TRY                     % try again
                            fprintf('Trying again...\n');   % starting over
                            continue;
                        case BUTTON_QUIT                    % quitx
                            fprintf('Quitting...\n\n');  	% quitting
                            return;                         % exit program
                        otherwise                           % cancel
                            fprintf('Quitting...\n\n'); 	% quitting
                            return;                         % exit program
                    end
                else
                    fprintf('Selecting "%s"...',filename);
                    fprintf('Loading...');
                    startTime = tic;
                    filename = fullfile(path,filename);
                    ImportedFile = importdata(filename);
                    [endTime,unit] = getEndTime(startTime);
                    fprintf('OK (%.2f %s)\n',endTime,unit);

                    filesInUse_cell_alloc = [filesInUse_cell;filename];
                    filesInUse_cell = filesInUse_cell_alloc;
                    numOfSamplesInFile = length(ImportedFile);
                    for sampleNum = 1:numOfSamplesInFile
                        fields = fieldnames(ImportedFile(sampleNum));
                        % Parameters
                        name = ImportedFile(sampleNum).Subject;
                        channelField_tf = containsi(fields,'Channel');
                        channelField = fields{channelField_tf};
                        channel = ImportedFile(sampleNum).(channelField);
                        fprintf('\tProcessing "%s %s"...',name,channel);
                        startTime = tic;
                        if ~isempty(filename_cell)
                            name_arr = [File.Data(:).Name]';
                            channel_arr = [File.Data(:).Channel]';
                            hasName_tf = containsi(name_arr,name);
                            hasChannel_tf = containsi(channel_arr,channel);
                            hasNameAndChannel = hasName_tf & hasChannel_tf;
                        else
                            hasNameAndChannel = false;
                        end

                        voltageField_tf = containsi(fields,'Voltage');
                        voltageField = fields{voltageField_tf};
                        voltage = ImportedFile(sampleNum).(voltageField);
                        currentField_tf = containsi(fields,'Current');
                        currentField = fields{currentField_tf};
                        current = ImportedFile(sampleNum).(currentField);
                        [current_fix,voltage_fix,~] = getNoOverflow(current,voltage,0);
                        [slope,intercept,r2] = getLinReg(voltage_fix,current_fix);
                        if r2 > 0 && ~hasNameAndChannel
                            sampleCount = sampleCount + 1;
                            resistance = abs(1 / slope);
                            File.Data(sampleCount).Name = name;
                            File.Data(sampleCount).Channel = channel;
                            File.Data(sampleCount).Max = max(voltage);
                            File.Data(sampleCount).Min = min(voltage);
                            File.Data(sampleCount).Start = voltage(1);
                            File.Data(sampleCount).StepSize = unique(diff(voltage));
                            File.Data(sampleCount).Voltage = voltage;
                            File.Data(sampleCount).Current = current;
                            File.Data(sampleCount).Resistance.Value = resistance;
                            File.Data(sampleCount).Resistance.Slope = slope;
                            File.Data(sampleCount).Resistance.Intercept = intercept;
                            File.Data(sampleCount).Resistance.R2 = r2;
                            File.Data(sampleCount).NumberOfSteps = length(voltage);
                        else
                            fprintf('Skipping...');
                        end
                        [endTime,unit] = getEndTime(startTime);
                        fprintf('OK (%.2f %s)\n',endTime,unit);
                    end
                    fprintf('\n');
                end
            end
        end
        numOfFiles_use = sprintf('Number of files: {\\bf%d}',numOfFiles);
        numOfSamples_use = sprintf('Number of samples: {\\bf%d}',sampleCount);
        files_prompt = {...
            numOfFiles_use,...
            numOfSamples_use};
        opts.Default = BUTTON_CONFIRM;       % option default
        read_quest = questdlg(...
            files_prompt, ...
            'Confirmation',...
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_QUIT,...
            opts);
        switch read_quest                       % apply choice
            case BUTTON_CONFIRM                 % check confirmation
                fprintf('Compiling data...');
                startTime = tic;
                filename_cell_alloc = [filename_cell;filesInUse_cell];
                filename_cell = filename_cell_alloc;
                numOfFilesTotal = numOfFilesTotal + numOfFiles;

                File.Files = filename_cell;
                [endTime,unit] = getEndTime(startTime);
                fprintf('OK (%.2f %s)\n',endTime,unit); % parameters confirmed
                fprintf('\tNumber of files: %d\n',numOfFiles);
                fprintf('\tNumber of samples: %d\n',sampleCount);
                fprintf('\n');
            case BUTTON_TRY                     % try again
                fprintf('Trying again...\n');   % starting over
                break;
            case BUTTON_QUIT                    % quit
                fprintf('Quitting...\n\n');  	% quitting
                return;                         % exit program
            otherwise                           % cancel
                fprintf('Quitting...\n\n'); 	% quitting
                return;                         % exit program
        end
    end
    fprintf('\n');

    switch check_quest  % apply choice
        case BUTTON_DONE
            numOfFiles_use = sprintf('Number of files: {\\bf%d}',numOfFilesTotal);
            numOfSamples_use = sprintf('Number of samples: {\\bf%d}',sampleCount);
            files_prompt = {...
                numOfFiles_use,...
                numOfSamples_use};
            opts.Default = BUTTON_CONFIRM;       % option default
            read_quest = questdlg(...
                files_prompt,'Confirmation',...
                BUTTON_CONFIRM,BUTTON_TRY,BUTTON_QUIT,...
                opts);
            switch read_quest                       % apply choice
                case BUTTON_CONFIRM                 % check confirmation
                    retrieving = false;                % confirm
                case BUTTON_TRY                     % try again
                    fprintf('Trying again...\n');   % starting over
                    break;
                case BUTTON_QUIT                    % quit
                    fprintf('Quitting...\n\n');  	% quitting
                    return;                         % exit program
                otherwise                           % cancel
                    fprintf('Quitting...\n\n'); 	% quitting
                    return;                         % exit program
            end
    end
end

end