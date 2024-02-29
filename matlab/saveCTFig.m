function [] = saveCTFig(...
    subjectName,...
    numOfSteps,...
    stepNum,...
    voltageBias,...
    savePath,...
    ctPlot)
%% Constants
YES = 1;
ZERO = 0;
ONE = 1;
TWO = 2;
THREE = 3;
FOUR = 4;
SAVE_FOLDER = 'CT';

%% Function
fprintf('Saving CT figure...');

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
        if voltageBias == ZERO
            voltageBias_char = sprintf('%05.2fV',voltageBias);
        else
            voltageBias_char = sprintf('%+05.2fV',voltageBias);
        end
        hasPlus = contains(voltageBias_char,'+');
        if hasPlus == true
            voltageBias_char = strrep(voltageBias_char,'+','pos');
        end
        hasMinus = contains(voltageBias_char,'-');
        if hasMinus == true
            voltageBias_char = strrep(voltageBias_char,'-','neg');
        end
        logNumOfSteps = log10(numOfSteps);
        numOfDigits = floor(logNumOfSteps) + ONE;
        if numOfDigits == ZERO
            filename_char = append(...
                subjectName_char,'_',...
                experiment_char,'_',...
                voltageBias_char);
        else
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
                voltageBias_char);
        end

        % Save
        filename_fig = append(filename_char,'.tif');
        filename_tif = fullfile(savePath,SAVE_FOLDER,filename_fig);
        count = TWO;
        while exist(filename_tif,'file')
            count_char = sprintf('_%d',count);
            filename_fig = append(filename_channel,count_char,'.tif');
            filename_tif = fullfile(savePath,SAVE_FOLDER,filename_fig);
            count = count + ONE;
        end
        print(ctPlot,'-dtiffn',filename_tif);
        fprintf('%s\n',filename_fig);
%         errFound = 0;
%     catch
%     end
% end

end