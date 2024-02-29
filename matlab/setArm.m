function [] = setArm(channelSelect,gpib,state)
%% Constants
MAX_NUM_OF_CHANNEL = 2;
MIN = 'MIN';
MAX = 'MAX';
DEF = 'DEF';
MAX_TIMER = 99999.99;
MIN_TIMER = 1e-3;

%% Function
fprintf('Setting arm layer...');

if isa(state,'char') || isa(state,'string')
    if contains(state,MIN,'IgnoreCase',true)
        timer = 1e-3;
    elseif contains(state,MAX,'IgnoreCase',true)
        timer = 99999.99;
    elseif contains(state,DEF,'IgnoreCase',true)
        timer = 1;
    end
elseif isa(state,'double')
    if state < MAX_TIMER || state > MIN_TIMER
        timer = state;
    else
        timer = 1;
    end
end

for channelNum = channelSelect
%     remainder = mod(channelNum,MAX_NUM_OF_CHANNEL);
    gpibNum = ceil(channelNum/MAX_NUM_OF_CHANNEL);
%     if remainder == 1
%         channel = 1;
%     else
%         channel = 2;
%     end
    timer_str = sprintf('ARM:TIMer %f',timer);
    fprintf(gpib(gpibNum),timer_str);
end
fprintf('%g s.\n',timer);

end