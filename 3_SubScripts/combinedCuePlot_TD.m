%% Plots figures for spwcmvgc

% maximum GC-axis value; if 0, defaults to max GC value of target event
if exist('axisLimit','var') == 0
    axisLimit = 0;
else
    plotMax = axisLimit;
end

if exist('saccFileString', 'var') == 0
    saccFileString = 'time_saccLFP_080415_in-out.mat'; %needs updated
end
if exist('targFileString', 'var') == 0
    targFileString = 'time_targLFP_080415_in-out.mat';
end

% load saccade event data
load(strcat(saccFileString, '.mat'), 'gc');
timeGC_sacc = gc;
saccMax = greatestMax(timeGC_sacc);

% load target event data
load(strcat(targFileString, '.mat'), 'gc');
timeGC_targ = gc;
targMax = greatestMax(timeGC_targ);

maxGC = greatestMax([saccMax targMax]);

% check for override
if axisLimit == 0
    plotMax = maxGC;
end
numVar = size(timeGC_sacc,1);


% isolate desired data time-period from original GC results
% NOTE: ensure selected length is same for targ/sacc
targMinTime = -200; % cue @ 400
targMaxTime = 400; %
saccMinTime = -400; % cue @ 600
saccMaxTime = 200; %

targMinIndex = floor((targMinTime+400)/1000*size(timeGC_targ,3)); % cue @ 400
targMaxIndex = floor((targMaxTime+400)/1000*size(timeGC_targ,3)); %
saccMinIndex = floor((saccMinTime+600)/1000*size(timeGC_sacc,3)); % cue @ 600
saccMaxIndex = floor((saccMaxTime+600)/1000*size(timeGC_sacc,3)); %

% finding max GC for target event (used if no override is given on line 4)
% for i=1:numVar
%     for j=1:numVar
%         if i ~= j
%             tempmaxgc = max(max(max(max(squeeze(specGC_sacc(:,i,j,:)))), maxGC),tempmaxgc);
%         end
%     end
% end


% setup target and saccade plots for selected time values
timeGC_targ_plot = timeGC_targ(:,:,targMinIndex:targMaxIndex);
timeGC_sacc_plot = timeGC_sacc(:,:,saccMinIndex:saccMaxIndex);
targ_time = targMinTime:(targMaxTime-targMinTime)/(targMaxIndex-targMinIndex):targMaxTime;
sacc_time = saccMinTime:(saccMaxTime-saccMinTime)/(saccMaxIndex-saccMinIndex):saccMaxTime;


%% plotting GCs

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
        plot(targ_time,squeeze(timeGC_targ_plot(i,j,:)),'LineWidth',3)
        axis xy
        axis([targMinTime+1 targMaxTime-1 0 plotMax]);
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
                text(targMinTime+50,0.8*plotMax,'Superficial','Color','red','FontSize',1.6*fontsize)
            case 2
                text(targMinTime+50,0.8*plotMax,'Intermediate','Color','red','FontSize',1.5*fontsize)
            case 3
                text(targMinTime+50,0.8*plotMax,'Deep','Color','red','FontSize',1.8*fontsize)
            otherwise
        end
            
        hold off
        
        % plotting sacc event
        subplot(numVar,numVar*2,(i-1)*2*numVar+2*j)
        hold on
        plot(sacc_time,squeeze(timeGC_sacc_plot(i,j,:)), 'LineWidth',3)
        axis xy
        axis([saccMinTime saccMaxTime 0 plotMax]);
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
        if i==j && i==ceil(numVar/2)
            xlabel('Time from event (ms)')
            ylabel('Granger Causality')
            set(gca,'fontsize',fontsize*1.5)
            set(get(gca,'xlabel'),'position',[-380 -70 0]) % dims: xpos, ypos, ???; note, for some odd reason, ypos is way more sensitive than xpos
            set(get(gca,'ylabel'),'position',[-2500 25 0])
        end
        hold off
    end
end

% maximize figure
pause(2);
jFrame = get(handle(gcf), 'JavaFrame');
jFrame.setMaximized(1);
