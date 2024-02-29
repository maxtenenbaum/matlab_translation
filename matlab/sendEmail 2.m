function [] = sendEmail(subjectName,emailAddress,endTime,emailFiles)
fclose('all');
%% CONSTANTS
SEC_TO_MIN = 1 / 60;
SEC_TO_HOUR = 1 / 3600;

%% Function
fprintf('Sending email...');

% Subject
emailSubject = sprintf('MATLB IV: %s',subjectName);

% Email name
atSign = find(emailAddress == '@');
emailName_idx = atSign - 1;
emailName = emailAddress(1:emailName_idx);

% Email message
emailMsg_greeting = sprintf('Hello %s,',emailName);
endTime_min = endTime * SEC_TO_MIN;
endTime_h = endTime * SEC_TO_HOUR;
emailMsg_1 = sprintf(...
    'Mesurement for "%s" completed in = %f s = %f min = %f h.',subjectName,endTime,endTime_min,endTime_h);
emailMsg_2 = 'The .xlsx file is attached to this message.';
emailMsg_closing = '-The Neural Interfaces Lab';
emailMessage = sprintf('%s\n\n%s\n%s\n\n%s',...
    emailMsg_greeting,...
    emailMsg_1,...
    emailMsg_2,...
    emailMsg_closing);

% Email attachments
if ~iscell(emailFiles)
    emailFiles_0_idx = find(emailFiles == 0);
    emailFiles(emailFiles_0_idx) = []; %#ok<FNDSB>
end
if ~isempty(emailFiles)
    emailAttachments = cellstr(emailFiles);
else
    emailAttachments = [];
end

% Send
try
    sendmail(...
        emailAddress,...
        emailSubject,...
        emailMessage,...
        emailAttachments);
catch
    sendmail(...
        emailAddress,...
        emailSubject,...
        emailMessage);
end
fprintf('OK.\n');

end