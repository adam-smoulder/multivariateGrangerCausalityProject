%% Plots figures for spwcmvgc

addpath(genpath(projectRoot)); % adds all needed scripts/functions to file path

% maximum GC-axis value; if 0, defaults to max GC value of target event
if exist('axisLimit','var') == 0
    axisLimit = 0;
else
    colorbarMax = axisLimit;
end

if exist('saccFileString', 'var') == 0
    saccFileString = 'saccLFP_080415_in-out.mat'; % needs updated
end
if exist('targFileString', 'var') == 0
    targFileString = 'targLFP_080415_in-out.mat';
end

% load saccade event data
load(strcat(saccFileString, '.mat'), 'gc');
specGC_sacc = gc;
saccMax = greatestMax(specGC_sacc);

% load target event data
load(strcat(targFileString, '.mat'), 'gc');
specGC_targ = gc;
targMax = greatestMax(specGC_targ);

numVar = size(specGC_targ,2);

maxGC = max([saccMax targMax]);
if axisLimit == 0
    colorbarMax = maxGC;
end


% isolate desired data time-period from original GC results
% NOTE: ensure selected length is same for targ/sacc
targMinTime = -200; % cue @ 400
targMaxTime = 400; %
saccMinTime = -400; % cue @ 600
saccMaxTime = 200; %

targMinIndex = floor((targMinTime+400)/1000*size(specGC_sacc,1)); % cue @ 400
targMaxIndex = floor((targMaxTime+400)/1000*size(specGC_sacc,1)); %
saccMinIndex = floor((saccMinTime+600)/1000*size(specGC_targ,1)); % cue @ 600
saccMaxIndex = floor((saccMaxTime+600)/1000*size(specGC_targ,1)); %

% setup target and saccade plots for selected time values
specGC_targ_plot = specGC_sacc(targMinIndex:targMaxIndex,:,:,:);
specGC_sacc_plot = specGC_targ(saccMinIndex:saccMaxIndex,:,:,:);
targ_time = targMinTime:(targMaxTime-targMinTime)/(targMaxIndex-targMinIndex):targMaxTime;
sacc_time = saccMinTime:(saccMaxTime-saccMinTime)/(saccMaxIndex-saccMinIndex):saccMaxTime;


%% plotting GCs

maxDispFreq = 60;   % maximum frequency to show on y-axis

% alignment constants; fiddle with them to change plots
vertPos = 1;
vertScale = 1.35;
horzScale = 1.3;
fontsize = 20;
figure(66)


% plotting (hint: it gets ugly)
for i = 1:numVar
    for j = 1:numVar
        % plotting targ event
        subplot(numVar,numVar*2,(i-1)*2*numVar+2*j-1)
        hold on
        imagesc(targ_time,freqs,squeeze(specGC_targ_plot(:,i,j,:))', [0, colorbarMax])
        colormap jet
        axis xy
        axis([targMinTime+1 targMaxTime-1 0 maxDispFreq-1]);
        sub_pos1 = get(gca,'position'); % get subplot axis position
        set(gca,'position',sub_pos1.*[1+(numVar+1-j)*.002 vertPos horzScale vertScale]) % stretch its width and height
        set(gca,'fontsize',fontsize)
        % selectively display x/y-axis depending on subplot
        if j~=1
            set(gca,'YTickLabel',[]);
        end
        if i~=numVar
            set(gca,'XTickLabel',[]);
        end
        plot(zeros(1,101), 0:100,'k--','LineWidth',3.5) % event time
        % label box (if along diagonal) at upper left corner
        switch i*(i==j)
            case 1
                text(targMinTime+50,maxDispFreq-10,'Superficial','Color','red','FontSize',1.6*fontsize)
            case 2
                text(targMinTime+50,maxDispFreq-10,'Intermediate','Color','red','FontSize',1.5*fontsize)
            case 3
                text(targMinTime+50,maxDispFreq-10,'Deep','Color','red','FontSize',1.8*fontsize)
            otherwise
        end
            
        hold off
        
        % plotting sacc event
        subplot(numVar,numVar*2,(i-1)*2*numVar+2*j)
        hold on
        imagesc(sacc_time,freqs,squeeze(specGC_sacc_plot(:,i,j,:))', [0, colorbarMax])
        colormap jet
        axis xy
        axis([saccMinTime saccMaxTime 0 maxDispFreq-1]);
        set(gca,'YTickLabel',[]);
        % selectively display x-axis depending on subplot
        if i~=numVar
            set(gca,'XTickLabel',[]);
        end
        sub_pos2 = get(gca,'position'); % get subplot axis position
        set(gca,'position',sub_pos2.*[1-(4-j)*.002 vertPos horzScale vertScale]) % stretch its width and height
        set(gca,'fontsize',fontsize)
        plot(zeros(1,101), 0:100,'k--','LineWidth',3.5) % event time

        % color bar and axis labels
        if i==1 && j ==1
            colorbar('Position', [0.94  0.13  0.02  0.85]) % dims: xpos, ypos, width, height)
            set(gca, 'CLim', [0,colorbarMax]);
        end
        if i==j && i==ceil(numVar/2)
            xlabel('Time from event (ms)')
            ylabel('Frequency (Hz)')
            set(gca,'fontsize',fontsize*1.5)
            set(get(gca,'xlabel'),'position',[-380 -70 0]) % dims: xpos, ypos, ???; note, for some odd reason, ypos is way more sensitive than xpos
            set(get(gca,'ylabel'),'position',[-2500 25 0])
        end
        hold off
    end
end
