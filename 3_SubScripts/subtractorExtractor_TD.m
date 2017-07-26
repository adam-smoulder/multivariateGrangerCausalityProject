% subtractorExtractor_TimeDomain:
% - save .mat for intarg = 1 (intarg) and intarg = 0 files from MVGC
% - load paths to these files
% - run this file!

%% load data
if exist('inTargFileString','var') == 0
    inTargFileString = 'time_sacclfp_bb_080415_intarg'; % these will need updated
end
if exist('outTargFileString','var') == 0
    outTargFileString = 'time_sacclfp_bb_080415_outtarg';
end
if exist('axisLimit', 'var') == 0
    axisLimit = 0;   %   maximum GC-axis value; if 0, defaults to max GC value
end

% example file names:
% saccLFP_080415_A_all
% pairwiseTarg_intarg
load(strcat(inTargFileString,'.mat'),'gc')
timeGC_in = gc;

load(strcat(outTargFileString,'.mat'),'gc')
timeGC_out = gc;

load(strcat(outTargFileString,'.mat'),'time') % should be same in both data


%% subtracting outtarg from intarg
clear gc
gc = timeGC_in - timeGC_out;

%% plot GCs
numVar = size(gc,2);

%finding max GC
maxGC = greatestMax(gc);

% check for override
if axisLimit == 0
    axisLimit = maxGC;
end

figure(66)
for i=1:numVar
    for j=1:numVar
        if i~=j
            subplot(numVar,numVar,(i-1)*numVar+j);
            plot(time,squeeze(gc(i,j,:)), 'LineWidth',3)
            ylabel('Granger Causality')
            axis xy
            axis([-inf, inf, 0, 1.2*axisLimit])
        end
    end
    
    % for reference
    subplot(numVar, numVar, numVar^2)
    title(['intarg = ' num2str(inTargVal)])
    xlabel(['Max GC = ' num2str(maxGC) '      points/eval = ' num2str(pointsPerEval)])
    % ylabel(['Spikes? ' num2str(spikes) '  spikeWind ' num2str(spikeDensityWind)])
end