function [] = sendEmail2(expID,subjectName,emailAddress,emailFiles,endTime)
%% Function
fprintf('Sending email...');
fclose('all');

% Subject
emailSubject = sprintf('MATLB %s: %s',expID,subjectName);

% Email name
atSign = find(emailAddress == '@');
emailName_idx = atSign - 1;
emailName = emailAddress(1:emailName_idx);

% Email message
emailMsg_greeting = sprintf('Hello %s,',emailName);
if iscell(endTime)
    endTime_num = endTime{1};
    unit = endTime{2};
    endTime_use = sprintf('%.2f %s',endTime_num,unit);
else
    endTime_min = endTime / 60;
    endTime_h = endTime_min / 60;
    endTime_d = endTime_h / 24;
    if endTime < 60
        endTime_use = sprintf('%.2f s',endTime);
    elseif endTime_min < 60
        endTime_use = sprintf('%.2f min',endTime_min);
    elseif endTime_h < 60
        endTime_use = sprintf('%.2f h',endTime_h);
    else
        endTime_use = sprintf('%.2f d',endTime_d);
    end
end
emailMsg_1 = sprintf(...
    'Mesurement for "%s" completed in %s.',subjectName,endTime_use);
emailMsg_2 = 'The file(s) is attached to this message.';
emailMsg_closing = '-The Neural Interfaces Lab';

% Email attachments
if ~iscell(emailFiles)
    emailFiles_0_idx = find(emailFiles == 0);
    emailFiles(emailFiles_0_idx) = []; %#ok<FNDSB>
    emailAttachments = cellstr(emailFiles);
end
if ~isempty(emailFiles)
    hasFile_idx = ~cellfun(@isempty,emailFiles);
    emailAttachments = emailFiles(hasFile_idx);
else
    emailMsg_2 = '';
end

% Send
emailMessage = sprintf('%s\n\n%s\n%s\n\n%s',...
    emailMsg_greeting,...
    emailMsg_1,...
    emailMsg_2,...
    emailMsg_closing);
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