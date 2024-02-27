function [File,quitProgram] = getParamIT(File)
%% Constants
% Dialog
BUTTON_CANCEL = 'Cancel';
BUTTON_CONFIRM = 'Confirm';
BUTTON_TRY = 'Try Again';
DIMS_DIALOG = [1 50];
% Dialog options
opts.Default = 'yes';
opts.Interpreter = 'tex';
% Values
FIXED_30V = 30;

%% Variables
confirmVoltageBias = false;
quitProgram = false;
voltageBias = FIXED_30V + 1;
duration = 0;

%% Function
try
    while confirmVoltageBias == false
        while voltageBias > FIXED_30V
            disp('Enter voltage bias...');
            % Dialog box
            titleInputVoltageBias = 'Voltage Bias';             % input title
            promptInputVoltageBias = {...
                'Voltage bias (V) {\bf(max \pm30)}:',...% voltage bias (V)
                'Duration (s) {\bf(use "inf" or "0" continuous unless stopped)}:'};
            defaultInputVoltageBias = {'','inf'};                               % input defaults
            inputVoltageBias = inputdlg(...	% input dialog
                promptInputVoltageBias,...    % input prompts
                titleInputVoltageBias,...     % input title
                DIMS_DIALOG,...             % dialog dimensions
                defaultInputVoltageBias,...   % input defaults
                opts);                      % dialog options
            cancelVoltageBias = isempty(inputVoltageBias);  % cancel dialog
            if cancelVoltageBias == true                     % cancel detected
                fprintf('Quitting...\n\n');             % quitting
                quitProgram = true;
                return;                                 % exit program
            end

            % Collect input
            voltageBias_cell = inputVoltageBias{1};       % voltage bias (cell)
            voltageBias = str2double(voltageBias_cell); % voltage bias (double)
            duration_cell = inputVoltageBias{2};       % voltage bias (cell)
            duration = str2double(duration_cell); % voltage bias (double)

            if abs(voltageBias) > FIXED_30V
                title = 'ERROR';
                prompt1 = 'VOLTAGE BIAS OUTSIDE RANGE!';
                disp(prompt1);
                prompt2 = 'Please enter correct value within range.';
                prompt = {prompt1,prompt2};
                balance = questdlg(prompt,title,BUTTON_TRY,BUTTON_CANCEL,opts);
                switch balance
                    case BUTTON_TRY                     % try again
                        fprintf('Trying again...\n\n'); % starting over
                    case BUTTON_CANCEL                  % quit
                        fprintf('Quitting...\n\n');     % quitting
                        quitProgram = true;
                        return;                         % exit program
                    otherwise                           % cancel
                        fprintf('Quitting...\n\n');     % quitting
                        quitProgram = true;
                        return;                         % exit program
                end
            end
        end

        % Confirm test parameters
        titleQuestVoltageBias = 'Confirm Voltage Bias';
        % Format questions
        voltageBias_use = sprintf('Voltage bias: {\\bf%g V}',voltageBias);	% formatted voltage bias
        if isinf(duration)
            duration_use = sprintf('Voltage bias: {\\bf\infty s}');	% formatted voltage bias
        else
            duration_use = sprintf('Voltage bias: {\\bf%g s}',duration);	% formatted voltage bias
        end
        promptQuestVoltageBias = {...
            voltageBias_use,...
            duration_use};                             % question prompt

        % Question box
        titleQuestVoltageBias = questdlg(...             	% question dialog
            promptQuestVoltageBias,...                    % question prompt
            titleQuestVoltageBias,...                   	% question title
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
            opts);                                      % dialog options
        % Confirmation
        switch titleQuestVoltageBias                       	% apply choice
            case BUTTON_CONFIRM                           	% check confirmation
                confirmVoltageBias = true;                       % confirm parameters
                File.Experiment.Parameters.VoltageBias = voltageBias;
                File.Experiment.Parameters.Duration = duration;
                File.Experiment.Parameters.NumberOfSteps = 1;
                fprintf('Test parameters set.\n\n'); % parameters confirmed
            case BUTTON_TRY                     % try again
                confirmVoltageBias = false;           % trying again
                fprintf('Trying again...\n\n'); % starting over
            case BUTTON_CANCEL                  % quit
                fprintf('Quitting...\n\n');     % quitting
                return;                         % exit program
            otherwise                           % cancel
                fprintf('Quitting...\n\n');     % quitting
                return;                         % exit program
        end
    end
catch
    quitProgram = true;
end

end