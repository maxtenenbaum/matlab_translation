function [File,quitProgram] = setKeithley(File)
%% Function
quitProgram = false;

% Display
File = setDisplay(File,'off');

% Power line frequency
File = setPowerLine(File,60);

% Ground connect mode
File = setGroundConnectMode2(File,'on');

% Source Delay
File = setSourceDelay(File,'off');

% Buffer Reading
File = setBuffer(File,'on');

% Data Format
File = setFormat(File,'ascii');

% Current Range
% [File,quitProgram] = selectCurrentRange(File);
% if quitProgram == true
%     fprintf('OK\n\n');
%     return;
% end
File = setCurrentRange2(File,'auto');       % set current range

% Speed
% [File,quitProgram] = selectSpeed(File);
% if quitProgram == true
%     fprintf('OK.\n\n');
%     return;
% end
File = setSpeed2(File,'fast');

% Auto-Zero
% [File,quitProgram] = selectAutoZero(File);
% if quitProgram == true
%     fprintf('OK.\n\n');
%     return;
% end
File = setAutoZero2(File,'on');	% set auto zero

% Rel Mode
% [File,quitProgram] = selectRelMode(File);
% if quitProgram == true
%     fprintf('OK.\n\n');
%     return;
% end
File = getOffset2(File,'on');     % get relative offset

end