% manually load data (currently 031315)
% remove goodLFP = 0
% sort out inTarg = 1 and inTarg = 0
% 

% vars
fs = 1000;                                  % sampling frequency
sortedLFPdata = zeros(135, 16, 1001); % dims: trial, channel, time
window = 200;                               % size of window for FFT
slide = 10;
nFFT = 1024;                                % number of points for FFT

% data input for target timepoint
for trial = 1:length(data)
    trialData = data(i);
    for i=1:length(trialData.channelOrder)
        sortedLFPdata(trial, trialData.channelOrder(i),:) = trialData.targlfpmat(i,:);
    end
end

%%

% isolate data desired to be analyzed
dataToUse = sortedLFPdata(:,1:2:13,:);


