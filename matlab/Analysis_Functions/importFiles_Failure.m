function [File,isQuit] = importFiles_Failure(File)
%% Constants
% Button
BUTTON_DONE = 'Done';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
BUTTON_QUIT = 'Quit';
% Dialog
CHECK_TITLE = 'Checking';
READ_TITLE = 'Confirmation';
% Options
opts.Interpreter = 'tex';   % option LaTeX

%% Variables
isQuit = false;
retrieving = true;
confirmFile = false;
filename_cell = {};
numOfFiles_arr = [];
vf_cell = {};
ft_cell = {};
sampingRate_arr = [];
diffTimeStep_arr = [];

%% Import Files
fprintf('Retrieving files...\n');
while retrieving
    filesInUse_cell = {};
    while ~confirmFile
        sampleCount = 0;
        confirmFile = false;
        isParamSame = false;
        vf_arr = [];
        ft_arr = [];
        [SelectedFiles,~] = getFiles('mat',false);
        if isempty(SelectedFiles)
            fprintf('Checking...');
            opts.Default = BUTTON_DONE;
            check_quest = questdlg(...
                '{\bfNo files selected.}', ...
                CHECK_TITLE,...
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
            Failure = struct( ...
                'Time',[], ...
                'Voltage',[]);
            Sample = struct( ...
                'Name',[], ...
                'Channel',[], ...
                'Time',[], ...
                'Voltage',[], ...
                'Current',[], ...
                'NumberOfSteps',[], ...
                'LastTimeStep',[], ...
                'Failure',Failure);
            voltageStep_list = [];
            timeStep_list = [];
            for fileNum = 1:numOfFiles
                filename = SelectedFiles(fileNum).name;
                isAlreadyInUse = contains2(filesInUse_cell,filename);
                if isAlreadyInUse
                    opts.Default = BUTTON_DONE;
                    check_quest = questdlg(...
                        'File already added.', ...
                        CHECK_TITLE,...
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

                    % Parameters
                    time_ = ImportedFile(1).Time;
                    samplingPeriod = unique(diff(time_));
                    voltage_ = ImportedFile(1).Voltage;
                    firstStep_idx = find(voltage_ == 0);
                    stepLength = length(firstStep_idx);
                    timeStep_s = stepLength / samplingPeriod;
                    timeStep_min = timeStep_s / 60;
                    secondStep_idx = firstStep_idx + timeStep_s;
                    stepDiff = voltage_(secondStep_idx) - voltage_(firstStep_idx);
                    voltageStep = stepDiff(1);

                    filesInUse_cell_alloc = [filesInUse_cell;filename];
                    filesInUse_cell = filesInUse_cell_alloc;
                    volageStep_list_alloc = [voltageStep_list;voltageStep];
                    voltageStep_list = volageStep_list_alloc;
                    timeStep_list_alloc = [timeStep_list;timeStep_s];
                    timeStep_list = timeStep_list_alloc;
                    numOfSamplesInFile = length(ImportedFile);
                    for sampleNum = 1:numOfSamplesInFile
                        name = ImportedFile(sampleNum).Subject;
                        channel = ImportedFile(sampleNum).Channel;
                        fprintf('\tProcessing "%s %s"...',name,channel);
                        startTime = tic;
                        time = ImportedFile(sampleNum).Time;
                        voltage = ImportedFile(sampleNum).Voltage;
                        current = ImportedFile(sampleNum).Current;
                        [current_fix,voltage_fix,time_fix] = getNoOverflow(current,voltage,time);
                        time_len = length(time_fix);
                        failureFound = find(current_fix > 1e-6,1);
                        if ~isempty(failureFound) && failureFound ~= 1
                            [failure_idx] = findFailureIndexAtChange(timeStep_s,time_len,current_fix);
                            vf_val = voltage_fix(failure_idx);
                            vf_arr_alloc = [vf_arr;vf_val];
                            vf_arr = vf_arr_alloc;
                            ft_val = time_fix(failure_idx);
                            ft_arr_alloc = [ft_arr;ft_val];
                            ft_arr = ft_arr_alloc;
                            [numOfSteps,~] = getNumOfSteps(ft_val,timeStep_s,voltageStep);
                            sampleCount = sampleCount + 1;
                            Sample(sampleCount).Name = name;
                            Sample(sampleCount).Channel = channel;
                            Sample(sampleCount).Time = time;
                            Sample(sampleCount).Voltage = voltage;
                            Sample(sampleCount).Current = current;
                            Sample(sampleCount).NumberOfSteps = numOfSteps;
                            Sample(sampleCount).Failure.Time = ft_val;
                            Sample(sampleCount).Failure.Voltage = vf_val;
                        else
                            fprintf('Skipping...');
                        end
                        [endTime,unit] = getEndTime(startTime);
                        fprintf('OK (%.2f %s)\n',endTime,unit);
                    end
                    fprintf('\n');

                    isVoltageStepSame = allSame(voltageStep_list);
                    isTimeStepSame = allSame(timeStep_list);
                    if isVoltageStepSame && isTimeStepSame
                        isParamSame = true;
                    else
                        isParamSame = false;
                    end
                end
            end
        end
        if isParamSame
            numOfFiles_use = sprintf('Number of files: {\\bf%d}',numOfFiles);
            voltageStep_use = sprintf('Voltage step (V): {\\bf%g}',voltageStep);
            timeStep_use = sprintf('Time step (min): {\\bf%g}',timeStep_min);
            numOfSamples_use = sprintf('Number of samples: {\\bf%d}',sampleCount);
            files_prompt = {...
                numOfFiles_use,...
                voltageStep_use,...
                timeStep_use, ...
                numOfSamples_use};
            opts.Default = BUTTON_CONFIRM;       % option default
            read_quest = questdlg(...
                files_prompt, ...
                READ_TITLE,...
                BUTTON_CONFIRM,BUTTON_TRY,BUTTON_QUIT,...
                opts);
            switch read_quest                       % apply choice
                case BUTTON_CONFIRM                 % check confirmation
                    fprintf('Compiling data...');
                    startTime = tic;
                    filename_cell_alloc = [filename_cell;filesInUse_cell];
                    filename_cell = filename_cell_alloc;
                    numOfFiles_arr_alloc = [numOfFiles_arr;numOfFiles];
                    numOfFiles_arr = numOfFiles_arr_alloc;
                    vf_cell_alloc = [vf_cell;vf_arr];
                    vf_cell = vf_cell_alloc;
                    ft_cell_alloc = [ft_cell;ft_arr];
                    ft_cell = ft_cell_alloc;

                    % Sampling
                    time1 = ft_arr(1);
                    time2 = ft_arr(2);
                    samplingPeriod = time2 / time1;
                    samplingRate = 1 / samplingPeriod;
                    samplingRate_arr_alloc = [sampingRate_arr;samplingRate];
                    sampingRate_arr = samplingRate_arr_alloc;
                    timeStep_arr_alloc = [diffTimeStep_arr;timeStep_min];
                    diffTimeStep_arr = timeStep_arr_alloc;
                    
                    idx = length(File.Data) + 1;
                    File.Files = filename_cell;
                    File.Data(idx).Name = sprintf('%g min',timeStep_min);
                    File.Data(idx).TimeStep = timeStep_s;
                    File.Data(idx).VoltageStep = voltageStep;
                    File.Data(idx).Sample = Sample;
                    File.Data(idx).Files = SelectedFiles;
                    File.Data(idx).NumberOfFiles = numOfFiles;
                    [endTime,unit] = getEndTime(startTime);
                    fprintf('OK (%.2f %s)\n',endTime,unit); % parameters confirmed
                    fprintf('\tNumber of files: %d\n',numOfFiles);
                    fprintf('\tVoltage step (V): %g\n',voltageStep);
                    fprintf('\tTime step (min): %g\n',timeStep_min);
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
    end
    fprintf('\n');

    switch check_quest  % apply choice
        case BUTTON_DONE
            numOfFileInUse_char = '';
            numOfGroup = length(numOfFiles_arr);
            for groupNum = 1:numOfGroup
                numOfFileInGroup = numOfFiles_arr(groupNum);
                if groupNum == 1
                    numOfFileInUse_use = sprintf('%d',numOfFileInGroup);
                else
                    numOfFileInUse_use = sprintf('%s, %d',numOfFileInUse_char,numOfFileInGroup);
                end
                numOfFileInUse_char = numOfFileInUse_use;
            end
            numOfFiles_use = sprintf('Number of files: {\\bf%s}',numOfFileInUse_char);
            numOfSamples_use = sprintf('Number of samples: {\\bf%d}',sampleCount);
            voltageStep_use = sprintf('Voltage step (V): {\\bf%g}',voltageStep);
            numOfTimeStep_char = '';
            numOfTimeStep = length(diffTimeStep_arr);
            for timeStepNum = 1:numOfTimeStep
                timeStepVal = diffTimeStep_arr(timeStepNum);
                if timeStepNum == 1
                    numOfTimeStep_use = sprintf('%d',timeStepVal);
                else
                    numOfTimeStep_use = sprintf('%s, %d',numOfTimeStep_char,timeStepVal);
                end
                numOfTimeStep_char = numOfTimeStep_use;
            end
            timeStep_use = sprintf('Time step (min): {\\bf%s}',numOfTimeStep_char);
            files_prompt = {...
                numOfFiles_use,...
                numOfSamples_use,...
                voltageStep_use,...
                timeStep_use};
            opts.Default = BUTTON_CONFIRM;       % option default
            read_quest = questdlg(...
                files_prompt,READ_TITLE,...
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