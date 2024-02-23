function [current_fix,voltage_fix,time_fix] = getNoOverflow(current,voltage,time)
%% Constants
ONE = 1;
CURRENT_OVERFLOW = 1e37;

%% Variables
data_len = length(current);
current_fix = zeros(data_len,1);
voltage_fix = zeros(data_len,1);
time_fix = zeros(data_len,1);
current_fix(:) = current(:);
voltage_fix(:) = voltage(:);
time_fix(:) = time(:);
current_len = length(current_fix);
voltage_len = length(voltage_fix);
time_len = length(time_fix);

%% Function
exclude_idx = find(current_fix >= CURRENT_OVERFLOW);

if ~isempty(exclude_idx)
    if current_len > ONE
        current_fix(exclude_idx) = [];
    end
    
    if voltage_len > ONE
        voltage_fix(exclude_idx) = [];
    end

    if time_len > ONE
        time_fix(exclude_idx) = [];
    end
    
end

end