function [voltageBias,quitProgram] = getVoltageBias()
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
confirmVoltageBias = 0;
quitProgram = 0;
voltageBias = FIXED_30V + 1;

%% Function
try
    while confirmVoltageBias == 0
        while voltageBias > FIXED_30V
            disp('Enter voltage bias...');
            % Dialog box
            titleInputVoltageBias = 'Voltage Bias';             % input title
            promptInputVoltageBias = 'Voltage bias (V) {\bf(max \pm30)}:';% voltage bias (V)
            defaultInputVoltageBias = {''};                               % input defaults
            inputVoltageBias = inputdlg(...	% input dialog
                promptInputVoltageBias,...    % input prompts
                titleInputVoltageBias,...     % input title
                DIMS_DIALOG,...             % dialog dimensions
                defaultInputVoltageBias,...   % input defaults
                opts);                      % dialog options
            cancelVoltageBias = isempty(inputVoltageBias);  % cancel dialog
            if cancelVoltageBias == 1                     % cancel detected
                fprintf('Quitting...\n\n');             % quitting
                quitProgram = 1;
                return;                                 % exit program
            end

            % Collect input
            voltageBias_cell = inputVoltageBias{1};       % voltage bias (cell)
            voltageBias = str2double(voltageBias_cell); % voltage bias (double)

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
                        quitProgram = 1;
                        return;                         % exit program
                    otherwise                           % cancel
                        fprintf('Quitting...\n\n');     % quitting
                        quitProgram = 1;
                        return;                         % exit program
                end
            end
        end

        % Confirm test parameters
        titleQuestVoltageBias = 'Confirm Voltage Bias';
        % Format questions
        voltageBias_use = sprintf('Voltage bias: {\\bf%g V}',voltageBias);	% formatted voltage bias
        promptQuestVoltageBias = voltageBias_use;                             % question prompt

        % Question box
        titleQuestVoltageBias = questdlg(...             	% question dialog
            promptQuestVoltageBias,...                    % question prompt
            titleQuestVoltageBias,...                   	% question title
            BUTTON_CONFIRM,BUTTON_TRY,BUTTON_CANCEL,... % buttons
            opts);                                      % dialog options
        % Confirmation
        switch titleQuestVoltageBias                       	% apply choice
            case BUTTON_CONFIRM                           	% check confirmation
                confirmVoltageBias = 1;                       % confirm parameters
                fprintf('Test parameters set.\n\n'); % parameters confirmed
            case BUTTON_TRY                     % try again
                confirmVoltageBias = 0;           % trying again
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
    voltageBias = 0;
    quitProgram = 1;
end

end