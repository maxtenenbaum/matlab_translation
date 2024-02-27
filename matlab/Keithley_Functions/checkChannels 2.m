function workingChannels = checkChannels()
fprintf('Checking channels..');

% workingChannels = [1 3 4 6];
workingChannels = 1:12;
badChannels = 2;
workingChannels(badChannels) = [];

for channelNum = workingChannels
    if channelNum == workingChannels(end)
        fprintf('%d...OK.\n',channelNum);
    else
        fprintf('%d...',channelNum);
    end
end

end