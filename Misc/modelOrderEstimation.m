% VAR Model order estimation
% TO USE:
% - Load data
% - Isolate desired data (so set your params and run the first two sections
%     of MVGC_TimeFreq or pairwiseMVGC_TimeFreq - then X only has the data 
%     you want to analyze remaining, like intarg/not, or spikes vs lfp, etc)
% - Run this script!


%load('pairwiseTarg_intarg.mat')
icregmode = 'OLS';  % information criteria regression mode ('OLS', 'LWR' or empty for default)
morder    = 'AIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 20;     % maximum model order for model order estimation

% Calculate information criteria up to specified maximum model order.

ptic('\n*** tsdata_to_infocrit\n');
[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(X,momax,icregmode);
ptoc('*** tsdata_to_infocrit took ');

% Plot information criteria.

figure(1); clf;
order = 1:momax;
subplot(1,2,1)
hold on
plot(order,AIC,'LineWidth',2)
plot(order,BIC,'LineWidth',2)
title('Model order estimation');
subplot(1,2,2)
hold on
plot(order(2:end),diff(AIC),'LineWidth',2)
plot(order(2:end),diff(BIC),'LineWidth',2)
legend('AIC','BIC')
title('Derivative of model order ests.');


fprintf('\nbest model order (AIC) = %d\n',moAIC);
fprintf('best model order (BIC) = %d\n',moBIC);

