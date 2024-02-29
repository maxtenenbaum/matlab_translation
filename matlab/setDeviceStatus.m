function gpib = setDeviceStatus(gpib,state)
%% Constants
ON = 'ON';
OFF = 'OFF';

%% Function
state = upper(state);
status = gpib.Status;
switch state
    case ON
        if contains2(status,OFF)
            fopen(gpib);
        end
    case OFF
        if contains2(status,ON)
            fclose(gpib);
        end
end

end