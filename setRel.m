function [offsetArray] = setRel(channelSelect,gpib,state)
%% Constants
FIRST = 1;
MAX_NUM_OF_GPIB = 3;
MAX_NUM_OF_CHANNEL = 2;
ONE = 1;
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
% channelSelect_len = length(channelSelect);

offsetMat = [];
% channel_idx = 0;

% samplingRate = 20;
% samplingControl = rateControl(samplingRate);
%% Function
fprintf('Capturing relative offset...');

if strcmpi(state,ON)
    % Turn on Rel Mode
    status = 'ON';
    for channelNum = FIRST:totalChannel
    %         channel_idx = channel_idx + ONE;
            remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
            gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
            if remainder == ONE
                channel = 1;
                calcChannel = channel + MAX_NUM_OF_CHANNEL;
            else
                channel = 2;
                calcChannel = channel + MAX_NUM_OF_CHANNEL;
            end
            setOnRel = sprintf('CALCulate%d:NULL:STATe %s',calcChannel,ON);
            fprintf(gpib(gpibNum),setOnRel);
    end
    
    % Capture Rel values
    numOfRepeats = 1000;
    for repeatNum = FIRST:numOfRepeats
        offsetArray = zeros(ONE,totalChannel);
        for channelNum = FIRST:totalChannel
            remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
            gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
            if remainder == ONE
                channel = 1;
                calcChannel = channel + MAX_NUM_OF_CHANNEL;
            else
                channel = 2;
                calcChannel = channel + MAX_NUM_OF_CHANNEL;
            end
            getRel = sprintf('CALCulate%d:NULL:ACQuire',calcChannel);
            fprintf(gpib(gpibNum),getRel);
            setRel = sprintf('CALCulate%d:FEED SENSe%d',calcChannel,channel);
            fprintf(gpib(gpibNum),setRel);
            outputOn = sprintf('OUTP%d %s,',channel,status);
            fprintf(gpib(gpibNum),outputOn);
            getOffset = sprintf('CALCulate%d:NULL:OFFSET?',calcChannel);
            fprintf(gpib(gpibNum),getOffset);
            offset_str = fscanf(gpib(gpibNum));
            offset = str2double(offset_str);
            offsetArray(channelNum) = offset;
        end
        offsetMat_alloc = [offsetMat;offsetArray];
        offsetMat = offsetMat_alloc;
%         waitfor(samplingControl);
    end
    
    % Turn off Rel Mode
    for channelNum = FIRST:totalChannel
        remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
        gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
        if remainder == ONE
            channel = 1;
            calcChannel = channel + MAX_NUM_OF_CHANNEL;
        else
            channel = 2;
            calcChannel = channel + MAX_NUM_OF_CHANNEL;
        end
        setOffRel = sprintf('CALCulate%d:NULL:STATe %s',calcChannel,OFF);
        fprintf(gpib(gpibNum),setOffRel);
            
    end
%     fprintf('OK.\n');
    
    % Save data
    offsetData = mean(offsetMat);
    offsetData_name = getVarName(offsetData);
    save(offsetFile,offsetData_name);
%     analysisProgram = fullfile(functionFolder,OFFSET_ANALYSIS);
%     run(analysisProgram);
    offsetArray_alloc = offsetData(channelSelect);
    offsetArray = offsetArray_alloc;
    
elseif strcmpi(state,OFF)
    status = 'OFF';
end

fprintf('%s.\n',status);

end