%% Parameters


figure();
hold on
xlabel('Time for saccade')
ylabel('Spike density (/s)')

low = 20;
step = 20;
high = low+step*4;

for spikeDensityWind = low:step:high
    dnobs     = 0;          % initial observations to discard per trial - 0; we can ignore as needed
    regmode   = 'OLS';      % VAR model estimation regression mode ('OLS', 'LWR' or empty for default - 'OLS' ?
    nlags     = 50;         % number of lags in VAR model - 1?
    dur       = 1;          % duration of trial (s) - 1
    fs        = 1000;       % sampling frequency (Hz) - 1000
    fres      = 8000;       % frequency resolution - 6000?
    nvars     = 3;          % number of channels data that's being compared - 3 (superficial, mid, deep)
    pointsPerEval = 20;     % evaluate GC at every ev-th sample - 10 is pretty fair
    windowSize = 100;       % observation regression window size - 100ish
    morder    = 5;         % model order (for real-world data should be estimated) - 2
    seed      = 0;          % random seed (0 for unseeded) - 0
    inTargVal = 1;          % if 0, only inTarg = 0 used, if 1, only inTarg = 1 used, o/w all
    
    nobs  = dur*fs+1;       % number of observations per trial
    tnobs = nobs+dnobs;     % total observations per trial for time series generation
    k = 1:tnobs;            % vector of time steps
    t = (k-dnobs-1)/fs;     % vector of times
    
    spikes = 1;             % are inputs a spike train? 1 = yes, 0 = no
    
    
    %Generate VAR test data (<mvgc_schema.html#3 |A3|>)
    
    % only select inTarg == 1 if desired
    switch inTargVal
        case 0
            dataToUse = data([data.inTarg] == 0);
        case 1
            dataToUse = data([data.inTarg] == 1);
        otherwise
            dataToUse = data;
    end
    
    
    % sort channels from default to align with indexes (CHANGE CUE IN HERE)
    sortedData = zeros(16, tnobs, length(dataToUse)); % dims: channel, time, trial
    for trial = 1:length(dataToUse)
        trialData = dataToUse(trial);
        for i=1:length(trialData.channelOrder)
            sortedData(trialData.channelOrder(i),:,trial) = trialData.saccspikemat(i,:); % (CHANGE CUE HERE)
        end
    end
    
    % convert spikes to spike density
    if spikes == 1
        for i = 1:16
            sortedData(i,:,:) = movsum(squeeze(sortedData(i,:,:)),spikeDensityWind);
        end
    end
    
    % % isolate data desired to be analyzed (adjust bad channels by date!)
    % % for superficial, mid, and deep SC
    X = zeros(3,1001, length(dataToUse));  % dims: depth (channel), time, trial
    X(1,:,:) = squeeze(sortedData(1,:,:) - sortedData(3,:,:));
    X(2,:,:) = squeeze(sortedData(5,:,:) - sortedData(7,:,:));
    X(3,:,:) = squeeze(sortedData(9,:,:) - sortedData(11,:,:));
    %
    % % for specific rows
    % X = sortedLFPdata([1 2 3 4 5 6 7 8 9 10 12 13 15],:,:); %this would take
    % days...
   
    
    plot(squeeze(X(1,:,75)))
    
end

legend('1','2','3','4','5');