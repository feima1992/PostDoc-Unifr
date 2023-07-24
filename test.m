startTime = [4.1983,4.2169,4.2362,7.4373,11.5295];
endTime = [4.2138,4.2359,4.2390,7.4485,11.5562];

threshould = 0.01;

% merge time intervals, if they are close enough to each other (threshould)
for i = 1:length(startTime)
    if i == 1
        newStartTime = startTime(i);
        newEndTime = endTime(i);
    else
        if startTime(i) - newEndTime(end) < threshould
            newEndTime(end) = endTime(i);
        else
            newStartTime = [newStartTime,startTime(i)];
            newEndTime = [newEndTime,endTime(i)];
        end
    end
end