function File = getOffset2(File,state)
%% Constants
TOTAL_NUMBER_CHANNELS = 12;
ALL_CHANNELS = 1:12;
MAX_NUM_SAMPLES = 1e4;
CHECK_SAMPLES = 200;
ON = 'ON';
OFF = 'OFF';
% FILENAME = 'OffsetData.mat';
% OFFSET_ANALYSIS = 'Analysis_Offset.m';

%% Variables
gpib_arr = File.Instrument.Object;
channelSelect = File.Experiment.Channels.Number;

try
    fileDate = datestr(now,'yymmdd_HHMMSS'); %#ok<*TNOW1>
catch
    fileDate = datetime('now','Format','yymmdd_HHMMSS');
end
functionFolder = pwd;
offsetFolder = 'Offset_Data';
offsetFilename = sprintf('%s_Kiethley_Offset.mat',fileDate);
offsetFile = fullfile(functionFolder,offsetFolder,offsetFilename);

offsetMat = zeros(MAX_NUM_SAMPLES,TOTAL_NUMBER_CHANNELS);
check_arr = zeros(1,TOTAL_NUMBER_CHANNELS);

numOfPoints = File.Instrument.Settings.Buffer.Points;
formatData = File.Instrument.Settings.Format;
isBinary = contains2(formatData,'BIN');

%% Function
fprintf('Capturing relative offset...');

if contains2(state,ON)
    % Turn on Rel Mode
%     status = 'ON';
    fprintf('OK\n');
    fprintf('\t');
    setSource(ALL_CHANNELS,gpib_arr,'on');
    fprintf('\t');
    setVoltageBias(ALL_CHANNELS,gpib_arr,0); % set voltage bias
%     for gpibNum = 1:MAX_NUM_OF_GPIB
%         gpib = gpib_arr(gpibNum);
%         fprintf(gpib,'SYSTem:LOCal');
%     end

    % Capture Rel values
    %     figure('Name','Offset');
    sampleNum = 0;
    startTime = tic;
    timestamp1 = toc(startTime);
    while ~all(check_arr)
        fprintf('\tSamples collected...');
        sampleNum = sampleNum + 1;
        fprintf('%d',sampleNum);
        offsetArray = zeros(1,TOTAL_NUMBER_CHANNELS);
        for channelNum = 1:TOTAL_NUMBER_CHANNELS
            [gpibNum,channel] = channelToDeviceChannel(channelNum);
            fprintf('...D%dC%d',gpibNum,channel);
%             startReadTime = tic;
            gpib = gpib_arr(gpibNum);
%             setDeviceStatus(gpib,'on');
%             if numOfPoints == 0
                channel_use = sprintf('FORMat:ELEMents CURRent%d',channel);
%             else
%                 channel_use = sprintf('FORMat:ELEMents:TRACe CURRent%d',channel);
%             end
            
            fprintf(gpib,channel_use);
            if isBinary
                fprintf(gpib,'TRACe:CLEar');
            end
            fprintf(gpib,'READ?');
            switch formatData
                case 'ASCII'
                    offset_raw = fgetl2(gpib);
                    offset = str2double(offset_raw);
                case 'BIN'
                    fprintf(gpib,'*WAI');
                    offset = fread(gpib,numOfPoints,'single');
                    errorCheck(gpib);
            end
%             [endReadTime,unit] = getEndTime(startReadTime);
%             fprintf('%e A (%.2f %s)\n',offset,endReadTime,unit);
            offsetArray(channelNum) = offset;

            if sampleNum > CHECK_SAMPLES
                samples = sampleNum-CHECK_SAMPLES:sampleNum;
                channelData = offsetMat(samples,channelNum);
                avg = mean(channelData);
                [slope,~,~] = getLinReg(samples,channelData);
%                 pow = floor(log10(avg));
                pow_check = 4;
    %                 check = 10^(pow - 4);
                percent_check = 10^(2 - pow_check);
    %             slope_check = 10^(avg_pow - pow_check);
                percent = slope / avg * 100;
                percent_mag = abs(percent);
                isPercentSmall = percent_mag < percent_check;
                if isPercentSmall
                    check_arr(channelNum) = true;
                end
                if check_arr(channelNum)
                    fprintf('*');
                end
            end
        end
        % offsetMat_alloc = [offsetMat;offsetArray];
        % offsetMat = offsetMat_alloc;
%         offsetMat(sampleNum,:) = offsetArray;
        offsetMat = addToBuffer(offsetMat,offsetArray);

        timestamp2 = toc(startTime);
        samplingPeriod = timestamp2 - timestamp1;
        samplingRate = 1 / samplingPeriod;
        timestamp1 = timestamp2;
        fprintf(',\t%f Hz\t(%f s)\n',samplingRate,samplingPeriod);
        
%         if sampleNum > CHECK_SAMPLES
%             for channelNum = 1:TOTAL_NUMBER_CHANNELS
%                 samples = sampleNum-CHECK_SAMPLES:sampleNum;
%                 channelData = offsetMat(samples,channelNum);
%                 avg = mean(channelData);
%                 [slope,~,~] = getLinReg(samples,channelData);
% %                 pow = floor(log10(avg));
%                 pow_check = 4;
%     %                 check = 10^(pow - 4);
%                 percent_check = 10^(2 - pow_check);
%     %             slope_check = 10^(avg_pow - pow_check);
%                 percent = slope / avg * 100;
%                 percent_mag = abs(percent);
%                 isPercentSmall = percent_mag < percent_check;
%                 if isPercentSmall
%                     check_arr(channelNum) = 1;
%                 end
%             end
            if all(check_arr) || sampleNum == MAX_NUM_SAMPLES
                break;
            end
%         end
    end
    setSource(ALL_CHANNELS,gpib_arr,'off');

    % Save data
    fprintf('Averaging samples...');
    offsetMean = mean(offsetMat);
    fprintf('OK\n');

    fprintf('Saving measurements...');
    offsetMat_name = getVarName(offsetMat);
    offsetMean_name = getVarName(offsetMean);
    save(offsetFile,offsetMat_name,offsetMean_name);
    fprintf('OK\n');

    fprintf('Setting offset...');
    offsetArray_alloc = offsetMean(channelSelect);
    offsetArray = offsetArray_alloc;
    status = offsetArray;
    fprintf('OK\n');

elseif contains2(state,OFF)
    fprintf('NO.\n');
    status = 'OFF';
end

File.Instrument.Settings.RelativeOffset = status;
fprintf('Relative offset...%s.\n',state);

end