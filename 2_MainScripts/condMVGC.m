% Performs Multivariate Granger Causality using the MVGC toolbox

% TODO: Implement pairwise analysis support on other scripts

tic;

%% Parameters
% Parameters that change between runs (with defaults)
if exist('inTargVal', 'var') == 0       % if not defined
    inTargVal = 1;                      % if 0, only inTarg = 0 used, if 1, only inTarg = 1 used, o/w all
    disp(['inTargVal = ', num2str(inTargVal), ' press anything to continue'])
    %pause();
end
if exist('cueString','var') == 0        % if not defined
    cueString = 'sacclfp';              % string with sacc/targ/go + spike/lfp
end
if exist('channelsToUse','var') == 0    % if not defined
    channelsToUse = [1 3; 5 7; 9 11];   % array with channel #s to use (sup. ; mid ; deep)
end
if exist('analysisType','var') == 0     % Conditional vs. pairwise analysis
    analysisType = 'cond';              % use "cond" and "pw" respectively
end
if exist('domain','var') == 0           % Domain of MVGC; spectral, time, or time by sum (spectral domain summed over frequencies)
    domain = 'SD';                      % use "SD", "TD", and "TDBySum" respectively
end
if exist('demeanTrialAvg','var') == 0   % flag for demeaning by trial avg (per channel)
    demeanTrialAvg = 0;                 % if 1, will demean all data by trial avg
end

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
modelOrder = 6;         % model order (for real-world data should be estimated) - ~6
seed      = 0;          % random seed (0 for unseeded) - 0

nobs  = dur*fs+1;       % number of observations per trial
tnobs = nobs+dnobs;     % total observations per trial for time series generation
k = 1:tnobs;            % vector of time steps
t = (k-dnobs-1)/fs;     % vector of times
    
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
        sortedData(trialData.channelOrder(i),:,trial) = trialData.targlfpmat(i,:); % (CHANGE LFPvsSPIKE CUE HERE)
        eval(strcat('sortedData(trialData.channelOrder(i),:,trial) = trialData.', cueString, 'mat(i,:);'));
    end
end

% % convert spikes to spike density
% if spikes == 1
%     for i = 1:16
%         sortedData(i,:,:) = movsum(squeeze(sortedData(i,:,:)),spikeDensityWind);
%     end
% end

if demeanTrialAvg
    sortedData = sortedData - repmat(mean(sortedData,3),1,1,size(sortedData,3));
end

% isolate data desired to be analyzed (subtracting is removing bias from
% voltage reference)
% for superficial, mid, and deep SC
X = zeros(3,1001, length(dataToUse));  % dims: depth (channel), time, trial
X(1,:,:) = squeeze(sortedData(channelsToUse(1,1),:,:) - sortedData(channelsToUse(1,2),:,:));
X(2,:,:) = squeeze(sortedData(channelsToUse(2,1),:,:) - sortedData(channelsToUse(2,2),:,:));
X(3,:,:) = squeeze(sortedData(channelsToUse(3,1),:,:) - sortedData(channelsToUse(3,2),:,:));

%% "Vertical" regression GC calculation

wnobs = modelOrder+windowSize;                  % number of observations in "vertical slice"
evalPoints = wnobs : pointsPerEval : nobs;      % GC evaluation points
enobs = length(evalPoints);                     % number of GC evaluations
nBins = fres+1;                                 % found mostly experimentally...
stepsize = (fs/2)/nBins;                        % max frequency is fs/2 (Nyquist)
freqs = 0:stepsize:(fs/2)-stepsize;             % frequency values
badCalcs = zeros(1,enobs);                      % record where calculations fail
if strcmp('SD',domain)
    gc = nan(enobs,nvars,nvars,fs/2);           % dims:  time, eq1, eq2, freq
elseif strcmp('TD',domain)
    gc = nan(nvars, nvars, enobs);              % dims:  eq1, eq2, time
elseif strcmp('TDBySum',domain)
    specGC = nan(enobs,nvars,nvars,fs/2);       % dims:  time, eq1, eq2, freq
    gc = nan(nvars, nvars, enobs);              % dims:  eq1, eq2, time
end

% loop through evaluation points
for e = 1:enobs
    j = evalPoints(e);
    fprintf('window %d of %d at time = %d',e,enobs,j);

    % convert time series data in window to VAR
    [A,SIG] = tsdata_to_var(X(:,j-wnobs+1:j,:),modelOrder,regmode);
    if isbad(A)
        fprintf(2,' *** skipping - VAR estimation failed\n');
        badCalcs(e) = 1;
        continue
    end

    % calculate autocovariance from VAR
    [G,info] = var_to_autocov(A,SIG);
    if info.error
        fprintf(2,' *** skipping - bad VAR (%s)\n',info.errmsg);
        badCalcs(e) = 1;
        continue
    end
    if info.aclags < info.acminlags % warn if number of autocov lags is too small (not a show-stopper)
        fprintf(2,' *** WARNING: minimum %d lags required (decay factor = %e)',info.acminlags,realpow(info.rho,info.aclags));
        badCalcs(e) = 1;
    end

    
    % Calculate GC for window
    if strcmp('SD',domain) && strcmp('cond',analysisType)
        a  = autocov_to_spwcgc(G,fres);
        gc(e,:,:,1:size(a,3)) = a;
    elseif strcmp('TD',domain) && strcmp('cond',analysisType)
        gc(:,:,e) = autocov_to_pwcgc(G);
    elseif strcmp('TDBySum',domain) && strcmp('cond',analysisType)
        a  = autocov_to_spwcgc(G,fres);
        specGC(e,:,:,1:size(a,3)) = a;
        gc(:,:,e) = squeeze(sum(specGC(e,:,:,:),4));
    elseif strcmp('SD',domain) && strcmp('pw',analysisType)
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
                    gc(e,count1,count2,1:size(b,3)) = b(1,2,:);
                    gc(e,count2,count1,1:size(b,3)) = b(2,1,:);
                end
            end
        end
    end
    
    if isbad(gc,false)
        fprintf(2,' *** skipping - GC calculation failed\n');
        badCalcs(e) = 1;
        continue
    end 
    
    fprintf('\n');
end

%% plot GCs
time = t(dnobs+1:end);
numVar = size(gc,2);
maxgc = greatestMax(gc);

figure(66)
for i=1:numVar
    for j=1:numVar
        if i~=j
            subplot(numVar,numVar,(i-1)*numVar+j);
            if strcmp(domain,'SD')
                imagesc(time,freqs,squeeze(gc(:,i,j,:))', [0, maxgc]) % why do I need to invert this?
                ylabel('Frequency (Hz)')
                axis xy
                axis([-inf, inf, 0, 50])
                colormap jet
                set(gca, 'CLim', [0,maxgc]);
            elseif strcmp(domain,'TD') || strcmp(domain,'TDBySum')
                subplot(numVar,numVar,(i-1)*numVar+j);
                plot(time,squeeze(timeGC(i,j,:)), 'LineWidth', 3) % why do I need to invert this?
                ylabel('Granger Causality')
                axis xy
                axis([-inf, inf, 0, 1.2*maxgc])
            end
        end
    end
end

% for reference
subplot(numVar, numVar, numVar^2)
if strcmp(domain, 'SD')
    set(gca, 'CLim', [0,maxgc]);
    c = colorbar;
    c.Label.String = 'GC';
    colorbar
end
title(['intarg = ' num2str(inTargVal)])
xlabel(['Max GC = ' num2str(maxgc) '      points/eval = ' num2str(pointsPerEval)])
% ylabel(['Spikes? ' num2str(spikes) '  spikeWind ' num2str(spikeDensityWind)])
toc