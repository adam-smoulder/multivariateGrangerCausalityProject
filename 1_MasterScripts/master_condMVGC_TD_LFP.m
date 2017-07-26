%% Conditional MVGC Spectral Domain combined script for LFP-LFP interactions
% Last update: 7/26/17

% TODO: automate enlarge of final figures and save as tif, clean up variables

% To run this script, do the following:
% startup MVGC
% set channels to use accordingly
% ensure you wish to run conditional MVGC in spectral domain

% BAD channels by dataset (do NOT use these):
% bb 031315: 11, 14
% bb 070915: 2, 7, 11, 14
% bb 071215: 11, 14
% bb 080415: none
% bl 031115: 2, 7, 11, 14
% bl 071415: 2, 7, 11, 14
% bl 072315_1: none
% bl 072315_2: none
% bl 112515: none

% typically use [1 3; 5 7; 9 11] if none bad

%% Setup

% variables
analysisType = 'cond';              % 'cond' = conditional, 'pw' = pairwise
monkey_date = 'bb_sc_080415';       % experiment, used for saving
signalType = 'lfp';                 % 'lfp' or 'spikes'
domain = 'TD';                      % 'SD' = spectral, 'TD' = time domain, 'TDbySum' = spectral then sum over frequencies
channelsToUse = [1 3; 5 7; 9 11];   % superficial ; mid ; deep - change all depending on experiment
demeanTrialAvg = 0;                 % 0 = do not demean data by trial avg, 1 = do so
axisLimit = 0;                      % if 0, axisLimit = maxGC (only used for subtractorExtractor)

% add file paths (only run within 1_MasterScripts folder)
cd .. % you are now located in Project folder after this line!!!
projectRoot = pwd;
addpath(genpath(projectRoot)); % adds all needed scripts/functions to file path
demeaned = ternaryOp(demeanTrialAvg, '_demeaned','');

clc % make sure you're clear before pulling the trigger!
disp('Check data is clear (or properly loaded) and filenames are clear! (press any key to cont.)')
pause();
if exist('data','var') == 0
    load(['4_Data/',monkey_date,'_mcell_spikelfp_cSC']);
end
disp('Check channels are correct! (press any key to cont.)')
pause();
 
%% MVGC to get SD GC for intarg, outtarg, and in-out for sacc and targ

% saccade, intarg
disp('...')
disp('saccade, intarg')
cueType = 'saccade';
cueString = getCueString(cueType,signalType); % used by MVGC scripts

inTargVal = 1;
inTargString = getInTargString(inTargVal);
inTarg_SaccFolderName = ['FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/IndividualCues/',cueType];
inTarg_SaccFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,demeaned];
eval(['mkdir ',inTarg_SaccFolderName]);
performMVGC;
saveas(figure(66), [inTarg_SaccFolderName,'/',inTarg_SaccFileString]);
clf 
close all
save([inTarg_SaccFolderName,'/',inTarg_SaccFileString]);

% saccade, outtarg
disp('...')
disp('saccade, outtarg')
inTargVal = 0;
inTargString = getInTargString(inTargVal);
outTarg_SaccFolderName = ['FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/IndividualCues/',cueType];
outTarg_SaccFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,'_',demeaned];
eval(['mkdir ',outTarg_SaccFolderName]);
performMVGC;
saveas(figure(66), [outTarg_SaccFolderName,'/',outTarg_SaccFileString]);
clf 
close all
save([outTarg_SaccFolderName,'/',outTarg_SaccFileString]);

% saccade, in - out
disp('...')
disp('saccade, in - out')
inMinusOutTarg_SaccFolderString = [projectRoot,'FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/IndividualCues/',cueType];
inMinusOutTarg_SaccFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,'_',demeaned];
eval(['mkdir ',inMinusOutTarg_SaccFolderString]);
inTargFileString = [inTarg_SaccFolderName,'/',inTarg_SaccFileString,'.mat'];
outTargFileString = [outTarg_SaccFolderName,'/',outTarg_SaccFileString,'.mat'];
performGCSubtraction;
saveas(figure(66), [inMinusOutTarg_SaccFolderString,'/',inMinusOutTarg_SaccFileString]); % save figure
clf
close all
save([inMinusOutTarg_SaccFolderString,'/',inMinusOutTarg_SaccFileString]); % save data

% target, intarg
disp('...')
disp('target, intarg')
cueType = 'target';
cueString = getCueString(cueType,signalType);

inTargVal = 1;
inTargString = getInTargString(inTargVal);
inTarg_TargFolderName = ['FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/IndividualCues/',cueType];
inTarg_TargFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,'_',demeaned];
eval(['mkdir ',inTarg_TargFolderName]);
performMVGC;
saveas(figure(66), [inTarg_TargFolderName,'/',inTarg_TargFileString]);
clf 
close all
save([inTarg_TargFolderName,'/',inTarg_TargFileString]);

% target, outtarg
disp('...')
disp('target, outtarg')
inTargVal = 0;
inTargString = getInTargString(inTargVal);
outTarg_TargFolderName = ['FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/IndividualCues/',cueType];
outTarg_TargFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,'_',demeaned];
eval(['mkdir ',outTarg_TargFolderName]);
performMVGC;
saveas(figure(66), [outTarg_TargFolderName,'/',outTarg_TargFileString]);
clf 
close all
save([outTarg_TargFolderName,'/',outTarg_TargFileString]);

% target, in - out
disp('...')
disp('target, in - out')
inMinusOutTarg_TargFolderString = [projectRoot,'FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/IndividualCues/',cueType];
inMinusOutTarg_TargFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,'_',demeaned];
eval(['mkdir ',inMinusOutTarg_TargFolderString]);
inTargFileString = [inTarg_TargFolderName,'/',inTarg_TargFileString,'.mat'];
outTargFileString = [outTarg_TargFolderName,'/',outTarg_TargFileString,'.mat'];
performGCSubtraction;
saveas(figure(66), [inMinusOutTarg_TargFolderString,'/',inMinusOutTarg_TargFileString]);
clf 
close all
save([inMinusOutTarg_TargFolderString,'/',inMinusOutTarg_TargFileString]);


%% Combined figure plots
% make folders for combined figures, axisLimit = 1
disp('...')
disp('Plot for figures')
switch domain
    case 'SD'
        axisLimit = 1;
    case 'TD'
        axisLimit = 0.2;
    case 'TDBySum'
        axisLimit = 1500;
    otherwise
        axisLimit = 0;
end
firstAxisLimitFolderString = [projectRoot,'FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/CombinedCues/',axisLimit];
eval(['mkdir ',firstAxisLimitFolderString]);

% combined figures, intarg, axisLimit = 1
disp('...')
disp(['intarg, max axis GC = ', axisLimit])
saccFileString = inTarg_SaccFileString; % Or whatever the name is in the script
targFileString = inTarg_TargFileString;
performCombinedPlot(domain);
inTargString = getInTargString(1);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimit];
saveas(figure(66), [firstAxisLimitFolderString,'/',fileName]);
clf
close all

% combined figures, outtarg, axisLimit = 1
disp('...')
disp(['outtarg, max axis GC = ', axisLimit])
saccFileString = outTarg_SaccFileString;
targFileString = outTarg_TargFileString;
performCombinedPlot(domain);
inTargString = getInTargString(0);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimit];
saveas(figure(66), [firstAxisLimitFolderString,'/',fileName]);
clf
close all

% combined figures, in-out, axisLimit = 1
disp('...')
disp(['in-out, max axis GC = ', axisLimit])
saccFileString = inMinusOutTarg_SaccFileString;
targFileString = inMinusOutTarg_TargFileString;
performCombinedPlot(domain);
inTargString = getInTargString(42);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimit];
saveas(figure(66), [firstAxisLimitFolderString,'/',fileName]);
clf 
close all



% create axisLimit = 0.5 folder
switch domain
    case 'SD'
        axisLimit = 0.5;
    case 'TD'
        axisLimit = 0.1;
    case 'TDBySum'
        axisLimit = 700;
    otherwise
        axisLimit = 0;
end
endsecondAxisLimitFolderString = [projectRoot,'FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/CombinedCues/',axisLimit];
eval(['mkdir ',secondAxisLimitFolderString]);

% combined figures, intarg, axisLimit = 0.5
disp('...')
disp(['intarg, max axis GC = ', axisLimit])
saccFileString = inTarg_SaccFileString;
targFileString = inTarg_TargFileString;
performCombinedPlot(domain);
inTargString = getInTargString(1);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimit];
saveas(figure(66), [secondAxisLimitFolderString,'/',fileName]);
clf
close all

% combined figures, outtarg, axisLimit = 0.5
disp('...')
disp(['outtarg, max axis GC = ', axisLimit])
saccFileString = outTarg_SaccFileString;
targFileString = outTarg_TargFileString;
performCombinedPlot(domain);
inTargString = getInTargString(0);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimit];
saveas(figure(66), [secondAxisLimitFolderString,'/',fileName]);
clf
close all

% combined figures, in-out, axisLimit = 0.5
disp('...')
disp(['in-out, max axis GC = ', axisLimit])
saccFileString = inMinusOutTarg_SaccFileString;
targFileString = inMinusOutTarg_TargFileString;
performCombinedPlot(domain);
inTargString = getInTargString(42);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimit];
saveas(figure(66), [secondAxisLimitFolderString,'/',fileName]);
clf
close all
