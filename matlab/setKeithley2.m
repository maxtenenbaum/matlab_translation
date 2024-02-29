function [File,quitProgram] = setKeithley2(File)
%% Function
% Display
File = setDisplay2(File,'off');

% Power line frequency
File = setPowerLine2(File,60);

% Ground connect mode
File = setGroundConnectMode3(File,'on');

% Source Delay
File = setSourceDelay2(File,'off');

% Current Range
[File,quitProgram] = selectCurrentRange2(File);
if quitProgram == true
    fprintf('OK.\n\n');
    return;
end

% Speed
[File,quitProgram] = selectSpeed2(File);
if quitProgram == true
    fprintf('OK.\n\n');
    return;
end

% Auto-Zero
[File,quitProgram] = selectAutoZero2(File);
if quitProgram == true
    fprintf('OK.\n\n');
    return;
end

% Rel Mode
[File,quitProgram] = selectRelMode(File);
if quitProgram == true
    fprintf('OK.\n\n');
    return;
end

% Buffer Reading
File = setBuffer2(File,'off');

end