% subtractorExtractor:
% - save .mat for intarg = 1 (intarg) and intarg = 0 files from MVGC
% - load paths to these files
% - run this file!

%% load data (assumes paths have been added)
if exist('inTargFileString','var') == 0
    inTargFileString = 'targLFP_080415_B_intarg.mat'; % will need to change this default
end
if exist('outTargFileString','var') == 0
    outTargFileString = 'targLFP_080415_C_outtarg.mat';
end
if exist('axisLimit', 'var') == 0
    axisLimit = 0;   %   maximum GC-axis value; if 0, defaults to max GC value
end

load(strcat(inTargFileString,'.mat'),'gc')
gc_in = gc;

load(strcat(outTargFileString,'.mat'),'gc')
gc_out = gc;

%% subtracting outtarg from intarg
clear gc
gc = gc_in - gc_out;

%% plot GCs
numVar = size(gc,2);

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
            imagesc(time,freqs,squeeze(gc(:,i,j,:))', [0, axisLimit]) % why do I need to transpose this?
            ylabel('Frequency (Hz)')
            axis xy
            axis([-inf, inf, 0, 50])
            colormap jet
            set(gca, 'CLim', [0,axisLimit]);
        end
    end
    
    % for reference
    subplot(numVar, numVar, numVar^2)
    set(gca, 'CLim', [0,axisLimit]);
    c = colorbar;
    c.Label.String = 'GC';
    title(['intarg = ' num2str(inTargVal)])
    xlabel(['Max GC = ' num2str(maxGC) '      points/eval = ' num2str(pointsPerEval)])
    % ylabel(['Spikes? ' num2str(spikes) '  spikeWind ' num2str(spikeDensityWind)])
end

colorbar
