function [outputArray] = movsum( inputArray, windowSize )
%MOVSUM Summary of this function goes here
%   Detailed explanation goes here
    outputArray = zeros(size(inputArray,1), size(inputArray,2));
    for i = 1:length(inputArray)
        if i < windowSize
            outputArray(i,:) = squeeze(sum(inputArray(1:i,:),1));
        else
            outputArray(i,:) = squeeze(sum(inputArray(i-windowSize+1:i,:),1));
        end
    end
end
