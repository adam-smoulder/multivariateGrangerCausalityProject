%% Conditional MVGC combined script
% Last update: 6/7/17

% TODO: Update variable names for different cues, check on subtractorExtractor, 
% update plotForFigure, figure out saves in here, automate enlarge of final
% figures and save as tif, clean up variables here as a whole

% load data before running

% channels:
% bad channels for bb 031315: 11, 14
% bad channels for bb 070915: 2, 7, 11, 14
% bad channels for bb 071215: 11, 14
% bad channels for bb 080415: none
% bad channels for bl 031115: 2, 7, 11, 14
% bad channels for bl 071415: 2, 7, 11, 14
% bad channels for bl 072315_1: none
% bad channels for bl 072315_2: none
% bad channels for bl 112515: none

% typically use [1 3; 5 7; 9 11] if none bad

clc
disp('Check data is loaded and filenames are clear! (press any key to cont.)')
pause();
monkey_Date = 'bb_080415'; % experiment, used for saving, still need to load data manually
channelsToUse = [1 3; 5 7; 9 11]; % superficial ; mid ; deep


%% MVGC to get GC for intarg, outtarg, and in-out for sacc and targ
demeanTrialAvg = 1;

% saccade, intarg
disp('...')
disp('saccade, intarg')
cueString = 'sacclfp';
inTargVal = 1;
MVGC_Spec_DemeanTrialAvg;
saveas(figure(66), strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_intarg'));
clf 
close all
save(strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_intarg'));

% saccade, outtarg
disp('...')
disp('saccade, outtarg')
inTargVal = 0;
MVGC_Spec_DemeanTrialAvg;
saveas(figure(66), strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_outtarg'));
clf 
close all
save(strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_outtarg'));

% saccade, in - out
disp('...')
disp('saccade, in - out')
inTargFileString = strcat('DM_',cueString,'_',monkey_Date,'_intarg');
outTargFileString = strcat('DM_',cueString,'_',monkey_Date,'_outtarg');
subtractorExtractor;
saveas(figure(66), strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_in-out'));
clf 
close all
save(strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_in-out'));


% target, intarg
disp('...')
disp('target, intarg');
cueString = 'targlfp';
inTargVal = 1;
MVGC_Spec_DemeanTrialAvg;
saveas(figure(66), strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_intarg'));
clf 
close all
save(strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_intarg'));

% target, outtarg
disp('...')
disp('target, outtarg')
inTargVal = 0;
MVGC_Spec_DemeanTrialAvg;
saveas(figure(66), strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_outtarg'));
clf 
close all
save(strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_outtarg'));

% target, in - out
disp('...')
disp('target, in-out')
inTargFileString = strcat('DM_',cueString,'_',monkey_Date,'_intarg');
outTargFileString = strcat('DM_',cueString,'_',monkey_Date,'_outtarg');
subtractorExtractor;
saveas(figure(66), strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_in-out'));
clf 
close all
save(strcat('adamFigsAndData/IndividualCues/conditional/',cueString,'/DM_',cueString,'_',monkey_Date,'_in-out'));


%% Combined figure plots
% make folders for combined figures
disp('...')
disp('Plot for figures')
eval(strcat('mkdir adamFigsAndData/Figure_Targ&SaccLFP/',monkey_Date));
maxAxisOverride = 1;
eval(strcat('mkdir adamFigsAndData/Figure_Targ&SaccLFP/',monkey_Date,'/',num2str(maxAxisOverride),'limit'));

% combined figures, intarg, maxAxisOverride = 1
disp('...')
disp('intarg, max axis GC = 1')
saccFileString = strcat('DM_sacclfp_',monkey_Date,'_intarg');
targFileString = strcat('DM_targlfp_',monkey_Date,'_intarg');
plotForFigure;
saveas(figure(66), strcat('adamFigsAndData/Figure_Targ&SaccLFP/',monkey_Date,'/',num2str(maxAxisOverride),'limit/DM_cond_intarg'));
clf 
close all

% combined figures, outtarg, maxAxisOverride = 1
disp('...')
disp('outtarg, max axis GC = 1')
saccFileString = strcat('DM_sacclfp_',monkey_Date,'_outtarg');
targFileString = strcat('DM_targlfp_',monkey_Date,'_outtarg');
plotForFigure;
saveas(figure(66), strcat('adamFigsAndData/Figure_Targ&SaccLFP/',monkey_Date,'/',num2str(maxAxisOverride),'limit/DM_cond_outtarg'));
clf 
close all

% combined figures, in-out, maxAxisOverride = 1
disp('...')
disp('in-out, max axis GC = 1')
saccFileString = strcat('DM_sacclfp_',monkey_Date,'_in-out');
targFileString = strcat('DM_targlfp_',monkey_Date,'_in-out');
plotForFigure;
saveas(figure(66), strcat('adamFigsAndData/Figure_Targ&SaccLFP/',monkey_Date,'/',num2str(maxAxisOverride),'limit/DM_cond_in-out'));
clf 
close all

% create maxAxisOverride = 0.5 folder
maxAxisOverride = 0.5;
eval(strcat('mkdir adamFigsAndData/Figure_Targ&SaccLFP/',monkey_Date,'/',num2str(maxAxisOverride),'limit'));

% combined figures, intarg, maxAxisOverride = 0.5
disp('...')
disp('intarg, max axis GC = 0.5')
saccFileString = strcat('DM_sacclfp_',monkey_Date,'_intarg');
targFileString = strcat('DM_targlfp_',monkey_Date,'_intarg');
plotForFigure;
saveas(figure(66), strcat('adamFigsAndData/Figure_Targ&SaccLFP/',monkey_Date,'/',num2str(maxAxisOverride),'limit/DM_cond_intarg'));
clf 
close all

% combined figures, outtarg, maxAxisOverride = 0.5
disp('...')
disp('outtarg, max axis GC = 0.5')
saccFileString = strcat('DM_sacclfp_',monkey_Date,'_outtarg');
targFileString = strcat('DM_targlfp_',monkey_Date,'_outtarg');
plotForFigure;
saveas(figure(66), strcat('adamFigsAndData/Figure_Targ&SaccLFP/',monkey_Date,'/',num2str(maxAxisOverride),'limit/DM_cond_outtarg'));
clf 
close all

% combined figures, in-out, maxAxisOverride = 0.5
disp('...')
disp('in-out, max axis GC = 0.5')
saccFileString = strcat('DM_sacclfp_',monkey_Date,'_in-out');
targFileString = strcat('DM_targlfp_',monkey_Date,'_in-out');
plotForFigure;
saveas(figure(66), strcat('adamFigsAndData/Figure_Targ&SaccLFP/',monkey_Date,'/',num2str(maxAxisOverride),'limit/DM_cond_in-out'));
clf 
close all
