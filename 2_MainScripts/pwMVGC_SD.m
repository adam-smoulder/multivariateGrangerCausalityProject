% Pairwise MVGC Spectrograms
% Ignore commented variables and expressions

% TO USE:
% - load desired data
% - change inTargVal (line 33) based on if you want to evaluate out of 
%       target (0), in target (1), or all data (any other #)
% - change target/type of neural data analyzed (line 59)
%       Ex: saccspikemat = spikes centered about time of saccade
% - run the file

%% Parameters
tic;

% Parameters that should not change between runs

dnobs     = 0;          % initial observations to discard per trial - 0; we can ignore as needed
regmode   = 'OLS';      % VAR model estimation regression mode ('OLS', 'LWR' or empty for default - 'OLS' ?
nlags     = 50;         % number of lags in VAR model - ?
dur       = 1;          % duration of trial (s) - 1
fs        = 1000;       % sampling frequency (Hz) - 1000
fres      = 8000;       % frequency resolution - 8000? Why is this so high? what is this?
nvars     = 3;          % number of channels data that's being compared - 3 (superficial, mid, deep)
pointsPerEval = 20;     % evaluate GC at every ev-th sample - 10 is pretty fair
windowSize = 100;       % observation regression window size - 100ish
morder    = 5;          % model order (for real-world data should be estimated) - 2
seed      = 0;          % random seed (0 for unseeded) - 0

nobs  = dur*fs+1;       % number of observations per trial
tnobs = nobs+dnobs;     % total observations per trial for time series generation
k = 1:tnobs;            % vector of time steps
t = (k-dnobs-1)/fs;     % vector of times


% Parameters that change between runs
inTargVal = 0;          % if 0, only inTarg = 0 used, if 1, only inTarg = 1 used, o/w all
% spikes = 0;              % are inputs a spike train? 1 = yes, 0 = no
% spikeDensityWind = 100;  % how many points per sum on spike density?


%% Isolate desired data
% produces X, which is what will be used for MVGC

% inTarg = 0 -> out of target, inTarg = 1 -> in target, otherwise -> all
switch inTargVal
    case 0
        dataToUse = data([data.inTarg] == 0);
    case 1
        dataToUse = data([data.inTarg] == 1);
    otherwise
        dataToUse = data;
end
    
% disp(['spikes = ', num2str(spikes),' press anything to continue'])
% pause();

% sort channels from default to align with indexes (CHANGE CUE IN HERE)
sortedData = zeros(16, tnobs, length(dataToUse)); % dims: channel, time, trial
for trial = 1:length(dataToUse)
    trialData = dataToUse(trial);
    for i=1:length(trialData.channelOrder)
        sortedData(trialData.channelOrder(i),:,trial) = trialData.golfpmat(i,:); % (CHANGE CUE HERE)
    end
end

% % convert spikes to spike density
% if spikes == 1
%     for i = 1:16
%         sortedData(i,:,:) = movsum(squeeze(sortedData(i,:,:)),spikeDensityWind);
%     end
% end

% % isolate data desired to be analyzed (adjust bad channels by date!)
% % for superficial, mid, and deep SC
X = zeros(3,1001, length(dataToUse));  % dims: depth (channel), time, trial
X(1,:,:) = squeeze(sortedData(1,:,:) - sortedData(3,:,:));
X(2,:,:) = squeeze(sortedData(5,:,:) - sortedData(7,:,:));
X(3,:,:) = squeeze(sortedData(9,:,:) - sortedData(11,:,:));


%% "Vertical" regression GC calculation

wnobs = morder+windowSize;                      % number of observations in "vertical slice"
evalPoints = wnobs : pointsPerEval : nobs;      % GC evaluation points
enobs = length(evalPoints);                     % number of GC evaluations
specGC = nan(enobs,nvars,nvars,fs/2);           % dims:  time, eq1, eq2, freq
nBins = fres+1;                                 % found mostly experimentally...
stepsize = (fs/2)/nBins;                        % max frequency is fs/2 (Nyquist)
freqs = 0:stepsize:(fs/2)-stepsize;             % frequency values

% timeGC = zeros(nvars,nvars,enobs);

% loop through evaluation points
for e = 1:enobs
    j = evalPoints(e);
    fprintf('window %d of %d at time = %d',e,enobs,j);

    % convert time series data in window to VAR
    [A,SIG] = tsdata_to_var(X(:,j-wnobs+1:j,:),morder,regmode);
    if isbad(A)
        fprintf(2,' *** skipping - VAR estimation failed\n');
        continue
    end

    % calculate autocovariance from VAR
    [G,info] = var_to_autocov(A,SIG);
    if info.error
        fprintf(2,' *** skipping - bad VAR (%s)\n',info.errmsg);
        continue
    end
    if info.aclags < info.acminlags % warn if number of autocov lags is too small (not a show-stopper)
        fprintf(2,' *** WARNING: minimum %d lags required (decay factor = %e)',info.acminlags,realpow(info.rho,info.aclags));
    end

%     timeGC(:,:,e) = autocov_to_pwcgc(G);
%     if isbad(timeGC,false)
%         fprintf(2,' *** skipping - GC calculation failed\n');
%         continue
%     end

    % Pairwise Spectral GC against time
    for count1 = 1:nvars   % for each pairwise GC we need to do...
        for count2 = count1:nvars
            clear PWAutoCov
            % isolating each interaction to find pairwise GCs
            if count1 ~= count2
                PWAutoCov(1,1,:) = G(count1,count1,:);
                PWAutoCov(1,2,:) = G(count1,count2,:);
                PWAutoCov(2,1,:) = G(count2,count1,:);
                PWAutoCov(2,2,:) = G(count2,count2,:);
                b = autocov_to_spwcgc(PWAutoCov,fres);
                specGC(e,count1,count2,1:size(b,3)) = b(1,2,:);
                specGC(e,count2,count1,1:size(b,3)) = b(2,1,:);
            end
        end
    end
    
    fprintf('\n');
end

%% plot GCs
time = t(dnobs+1:end);
maxgc = 0;
numVar = size(specGC,2);


%finding max GC
for i=1:numVar
    for j=1:numVar
        if i ~= j
            tempmaxgc = max(max(max(squeeze(specGC(:,i,j,:)))), maxgc);
            if tempmaxgc > maxgc
                maxgc = tempmaxgc;
            end
        end
    end
end

figure(66)
for i=1:numVar
    for j=1:numVar
        if i~=j
            subplot(numVar,numVar,(i-1)*numVar+j);
            imagesc(time,freqs,squeeze(specGC(:,i,j,:))', [0, maxgc]) % why do I need to invert this?
            ylabel('Frequency (Hz)')
            axis xy
            axis([-inf, inf, 0, 50])
            colormap jet
            set(gca, 'CLim', [0,maxgc]);
        end
    end
    
    % for reference
    subplot(numVar, numVar, numVar^2)
    set(gca, 'CLim', [0,maxgc]);
    c = colorbar;
    c.Label.String = 'GC';
    title(['intarg = ' num2str(inTargVal)])
    xlabel(['Max GC = ' num2str(maxgc) '      points/eval = ' num2str(pointsPerEval)])
    % ylabel(['Spikes? ' num2str(spikes) '  spikeWind ' num2str(spikeDensityWind)])
end

colorbar

toc