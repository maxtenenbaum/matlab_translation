function [File,quitProgram] = getProcessingParam(File)
%% Constants
% Dialog
% buttons
BUTTON_CONFIRM = 'Confirm'; % confirm button
BUTTON_TRY = 'Start Over';  % start over button
BUTTON_CANCEL = 'Cancel';   % cancel button
% options
opts.Default = 'yes';       % option dedault
opts.Interpreter = 'tex';   % option LaTeX
% dimensions
DIMS_DIALOG = [1 75];

%% Variables
expID = File.Experiment.ID;
confirmSteadyStateParam = false;
quitProgram = false;

%% Function
if strcmpi(expID,'IV')
    fprintf('Enter steady state parameters...');
    while confirmSteadyStateParam == false
        % Dialog box
        titleInputSteadyState = 'Steady State Parameters';  % input title
%         (Recommendation: 200 for resistors, 600 for IDE)
        bufferPrompt = sprintf('Buffer length (n) {\\bf(smaller is more sensitive but can take longer):\n}');
        promptInputSteadyState = {...                                       % input prompt
            bufferPrompt,...                                                % buffer length
            'Standard devations (s) {\bf(larger accepts more values)}:'};   % standard deviation
        defaultInputSteadyState = {'300','3'};      % input defaults
        inputSteadyState = inputdlg(...% input dialog
            promptInputSteadyState,... % input prompts
            titleInputSteadyState,...  % input title
            DIMS_DIALOG,...            % dialog dimensions
            defaultInputSteadyState,...% input defaults
            opts);                     % dialog options
        cancelSteadyState = isempty(inputSteadyState);    % cancel dialog

        % Collect input
        bufferLength_cell = inputSteadyState{1};    	% buffer length (cell)
        bufferLength = str2double(bufferLength_cell);	% buffer length (double)
        goodStdDev_cell = inputSteadyState{2};          % standard deviations (cell)
        numOfSD = str2double(goodStdDev_cell);   	% standard deviations (double)
        if cancelSteadyState == true       % cancel detected
            fprintf('\nQuitting...'); 	% quitting
            quitProgram = true;
            return;                     % exit program
        end

        % Confirm voltage parameters
        titleQuestSteadyStateParam = 'Confirm Steady State Parameters';
        % Format questions
        bufferLength_use = sprintf('Buffer length: {\\bfn = %g}',bufferLength);         % formatted buffer length
        goodStdDev_use = sprintf('Standard deviations: {\\bf\\pm%g SD}',numOfSD);   % formatted steady slope
        promptQuestSteadyStateParam = {...  % question prompt
            bufferLength_use,...            % buffer length
            goodStdDev_use};                % standard deviations

        % Question box
        titleQuestSteadyStateParam = questdlg(...       % question dialog
            promptQuestSteadyStateParam,...             % question prompt
            titleQuestSteadyStateParam,...              % question title
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
            opts);                                      % dialog options
        % Confirmation
        switch titleQuestSteadyStateParam 	% apply choice
            case BUTTON_CONFIRM             % check confirmation
                confirmSteadyStateParam = true;% confirm parameters
                File.Experiment.Parameters.BufferLength = bufferLength;
                File.Experiment.Parameters.StandardDeviations = numOfSD;
                numOfSteps = File.Experiment.Parameters.NumberOfSteps;
                channelSelect = File.Experiment.Channels.Number;
                channelSelect_len = length(channelSelect);
                fprintf('OK.\n');         % parameters confirmed
            case BUTTON_TRY                         % try again
                fprintf('\nTrying again...\n\n');   % starting over
            case BUTTON_CANCEL                      % quit
                fprintf('\nQuitting...');	% quitting
                quitProgram = true;
                return;                         % exit program
            otherwise                           % cancel
                fprintf('\nQuitting...'); 	% quitting
                quitProgram = true;
                return;                         % exit program
        end
    end
else
    File.Instrument = rmfield(File.Instrument,'SteadyState');
end

end