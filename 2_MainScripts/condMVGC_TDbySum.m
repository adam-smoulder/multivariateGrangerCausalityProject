% Conditional MVGC Spectrograms
% TODO: Figure out how to only sum over frequencies up to 60Hz

% TO USE, FOLLOW THESE INSTRUCTIONS (Adam update this):
% - load desired data and startup MVGC
% - change inTargVal (~line 35) based on if you want to evaluate out of 
%       target (0), in target (1), or all data (any other #)
% - change target/type of neural data analyzed (~line 60)
%       Ex: saccspikemat = spikes centered about time of saccade
% - adjust channels used for accuracy (~line 76)
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
pointsPerEval = 10;     % evaluate GC at every ev-th sample - 10 is pretty fair
windowSize = 100;       % observation regression window size - 100ish
morder    = 5;          % model order (for real-world data should be estimated) - ~5
seed      = 0;          % random seed (0 for unseeded) - 0

nobs  = dur*fs+1;       % number of observations per trial
tnobs = nobs+dnobs;     % total observations per trial for time series generation
k = 1:tnobs;            % vector of time steps
t = (k-dnobs-1)/fs;     % vector of times

% Parameters that change between runs (with defaults)
if exist('inTargVal', 'var') == 0       % if not defined by outside script
    inTargVal = 1;                      % if 0, only inTarg = 0 used, if 1, only inTarg = 1 used, o/w all
    disp(['inTargVal = ', num2str(inTargVal), ' press anything to continue'])
    pause();
end
if exist('cueString','var') == 0        % if not defined
    cueString = 'sacclfp';              % string with sacc/targ/go + spike/lfp
end
if exist('channelsToUse','var') == 0    % if not defined
    channelsToUse = [1 3; 5 7; 9 11];   % array with channel #s to use (sup. ; mid ; deep)
end
% spikes = 0;                           % are inputs a spike train? 1 = yes, 0 = no
% spikeDensityWind = 100;               % how many points per sum on spike density?


%% Isolate desired data
% produces variable X, which is what will be used for MVGC

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


% sort channels from default to align with indexes (CHANGE CUE IN HERE)
sortedData = zeros(16, tnobs, length(dataToUse)); % dims: channel, time, trial
for trial = 1:length(dataToUse)
    trialData = dataToUse(trial);
    for i=1:length(trialData.channelOrder)
        sortedData(trialData.channelOrder(i),:,trial) = trialData.targlfpmat(i,:); % (CHANGE CUE HERE)
        eval(strcat('sortedData(trialData.channelOrder(i),:,trial) = trialData.', cueString, 'mat(i,:);'));
    end
end

% % convert spikes to spike density
% if spikes == 1
%     for i = 1:16
%         sortedData(i,:,:) = movsum(squeeze(sortedData(i,:,:)),spikeDensityWind);
%     end
% end

% isolate data desired to be analyzed
% for superficial, mid, and deep SC
X = zeros(3,1001, length(dataToUse));  % dims: depth (channel), time, trial
X(1,:,:) = squeeze(sortedData(channelsToUse(1,1),:,:) - sortedData(channelsToUse(1,2),:,:));
X(2,:,:) = squeeze(sortedData(channelsToUse(2,1),:,:) - sortedData(channelsToUse(2,2),:,:));
X(3,:,:) = squeeze(sortedData(channelsToUse(3,1),:,:) - sortedData(channelsToUse(3,2),:,:));

%% "Vertical" regression GC calculation

wnobs = morder+windowSize;                      % number of observations in "vertical slice"
evalPoints = wnobs : pointsPerEval : nobs;      % GC evaluation points
enobs = length(evalPoints);                     % number of GC evaluations
nBins = fres+1;                                 % found mostly experimentally...
stepsize = (fs/2)/nBins;                        % max frequency is fs/2 (Nyquist)
freqs = 0:stepsize:(fs/2)-stepsize;             % frequency values

timeGC = NaN(nvars,nvars,enobs);                % dims: affected, affector, time
specGC = nan(enobs,nvars,nvars,fs/2);           % dims:  time, eq1, eq2, freq

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
    
    % Calculate spectral GC for window
    a  = autocov_to_spwcgc(G,fres); % conditional!!
    specGC(e,:,:,1:size(a,3)) = a;
    timeGC(:,:,e) = squeeze(sum(specGC(e,:,:,:),4));
    
%     timeGC = NaN(nvars,nvars,enobs);                % dims: affected, affector, time
%     specGC = nan(enobs,nvars,nvars,fs/2);           % dims:  time, eq1, eq2, freq

    
    fprintf('\n');
end

%% plot GCs
time = t(1:length(t)/enobs:end);
maxgc = 0;
numVar = size(timeGC,1);


%finding max GC
maxgc = max(max(max(timeGC)));

figure(66)
for i=1:numVar
    for j=1:numVar
        if i~=j
            subplot(numVar,numVar,(i-1)*numVar+j);
            plot(time,squeeze(timeGC(i,j,:)), 'LineWidth', 3) % why do I need to invert this?
            ylabel('Granger Causality')
            axis xy
            axis([-inf, inf, 0, 1.2*maxgc])
        end
    end
    
    % for reference
    subplot(numVar, numVar, numVar^2)
    title(['intarg = ' num2str(inTargVal)])
    xlabel(['Max GC = ' num2str(maxgc) '      points/eval = ' num2str(pointsPerEval)])
    % ylabel(['Spikes? ' num2str(spikes) '  spikeWind ' num2str(spikeDensityWind)])
end

toc