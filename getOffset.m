function [offsetArray] = getOffset(channelSelect,gpib,state)
%% Constants
FIRST = 1;
MAX_NUM_OF_GPIB = 3;
MAX_NUM_OF_CHANNEL = 2;
ZERO = 0;
ONE = 1;
HUNDRED = 100;
ON = 'ON';
OFF = 'OFF';
% FILENAME = 'OffsetData.mat';
% OFFSET_ANALYSIS = 'Analysis_Offset.m';

%% Variables
fileDate = datestr(now,'yymmdd_HHMMSS');
functionFolder = pwd;
% programFolder_backslash_idx = strfind(functionFolder,'\');
% programFolder_idx = programFolder_backslash_idx(end);
% programFolder = functionFolder(FIRST:programFolder_idx-ONE);
offsetFolder = 'Offset_Data';
offsetFilename = sprintf('%s_Kiethley_Offset.mat',fileDate);
offsetFile = fullfile(functionFolder,offsetFolder,offsetFilename);

totalChannel = MAX_NUM_OF_GPIB * MAX_NUM_OF_CHANNEL;
offsetMat = [];
checkMat = zeros(1,totalChannel);

% samplingRate = 20;
% samplingControl = rateControl(samplingRate);

%% Function
fprintf('Capturing relative offset...');

if strcmpi(state,ON)
    % Turn on Rel Mode
    status = 'ON';
    fprintf('OK.\n');
    setSource(channelSelect,gpib,'on');
    setVoltageBias(0,channelSelect,gpib); % set voltage bias
    
    % Capture Rel values
    numOfSamples = 1000;
%     figure('Name','Offset');
    for sampleNum = FIRST:numOfSamples
        offsetArray = zeros(ONE,totalChannel);
        for channelNum = FIRST:totalChannel
            remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
            gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
            if remainder == ONE
                channel = 1;
            else
                channel = 2;
            end
            selectChannel = sprintf('FORMat:ELEMents CURRent%d',channel);
            fprintf(gpib(gpibNum),selectChannel);
            fprintf(gpib(gpibNum),'READ?');

            offset_str = fscanf(gpib(gpibNum));
            offset = str2double(offset_str);
            offsetArray(channelNum) = offset;
        end
        
%         if sampleNum == FIRST
%             fprintf('OK.\n');
%         end
        
        fprintf('Collecting samples...');
        
        
%         fprintf('Compiling samples...')
        offsetMat_alloc = [offsetMat;offsetArray];
        offsetMat = offsetMat_alloc;
        fprintf('%d.\n',sampleNum);
        
        for channelNum = FIRST:totalChannel
            channelData = offsetMat(:,channelNum);
            avg = mean(channelData);
            idx_array = 1:sampleNum;
            linReg = polyfit(idx_array,channelData,1);
            slope = linReg(1);
            pow = floor(log10(avg));
            check = 10^(pow-3);
            if slope < check
                checkMat(channelNum) = 1;
            end
        end
        if all(checkMat)
            break;
        end
%         fprintf('OK.\n');
%         waitfor(samplingControl);
    end
    
    setSource(channelSelect,gpib,'off');
    
    % Save data
    fprintf('Averaging samples...');
    offsetMean = mean(offsetMat);
    fprintf('OK.\n');
    
    fprintf('Saving measurements...');
    offsetMat_name = getVarName(offsetMat);
    offsetMean_name = getVarName(offsetMean);
    save(offsetFile,offsetMat_name,offsetMean_name);
%     analysisProgram = fullfile(functionFolder,OFFSET_ANALYSIS);
%     run(analysisProgram);
    fprintf('OK.\n');
    
    fprintf('Setting offset...');
    offsetArray_alloc = offsetMean(channelSelect);
    offsetArray = offsetArray_alloc;
    fprintf('OK.\n');
    
elseif strcmpi(state,OFF)
    fprintf('NO.\n');
    status = 'OFF';
end

fprintf('Relative offset...%s.\n',status);

end