function [] = saveStepsFig(...
    subjectName,...
    numOfSteps,...
    stepNum,...
    lowerLimit,...
    upperLimit,...
    channelSelect_len,...
    channelNameList,...
    savePath,...
    stepsFigure)
%% Constants
YES = 1;
FIRST = 1;
ZERO = 0;
ONE = 1;
TWO = 2;
THREE = 3;
FOUR = 4;
SAVE_FOLDER = 'Steps';

%% Function
fprintf('Saving Steps figure...\n');

try
    folderPath = fullfile(savePath,SAVE_FOLDER);
    status = mkdir(folderPath);
catch
end

% errFound = 1;
% while errFound == YES
%     try
        for channel_idx = FIRST:channelSelect_len
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
            logNumOfSteps = log10(numOfSteps);
            numOfDigits = floor(logNumOfSteps) + ONE;
            switch numOfDigits
                case ONE
                    stepNum_char = sprintf('Step%01d',stepNum);
                case TWO
                    stepNum_char = sprintf('Step%02d',stepNum);
                case THREE
                    stepNum_char = sprintf('Step%03d',stepNum);
                case FOUR
                    stepNum_char = sprintf('Step%04d',stepNum);
            end
            filename_char = append(...
                subjectName_char,'_',...
                experiment_char,'_',...
                stepNum_char,'_',...
                limits_char);
        
            channelName_char = channelNameList(channel_idx);
            filename_channel_char = sprintf('%s_%s',filename_char,channelName_char);% filename for .tif file (char)
            filename_channel = convertCharsToStrings(filename_channel_char);     	% filename string for .tif file (string)

            % Save
            filename_fig = append(filename_channel,'.tif');
            filename_tif = fullfile(savePath,SAVE_FOLDER,filename_fig);
            count = TWO;
            while exist(filename_tif,'file')
                count_char = sprintf('_%d',count);
                filename_fig = append(filename_channel,count_char,'.tif');
                filename_tif = fullfile(savePath,SAVE_FOLDER,filename_fig);
                count = count + ONE;
            end
            print(stepsFigure(channel_idx),'-dtiffn',filename_tif);
            fprintf('%s\n',filename_fig);
%             errFound = 0;
        end
%     catch
%     end
% end

end