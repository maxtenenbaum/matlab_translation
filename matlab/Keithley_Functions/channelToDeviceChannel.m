function [gpibNum,channel] = channelToDeviceChannel(channelNum)
%% Function
remainder = rem(channelNum,2);
gpibNum = ceil(channelNum/2);
if remainder == 1
    channel = 1;
else
    channel = 2;
end

end