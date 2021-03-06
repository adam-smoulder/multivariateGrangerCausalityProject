%% MasterMVGC script (only run within 1_MasterScripts folder)
%  runs different types of MVGC analysis based on the following parameters:
% variables
% analysisType           % 'cond' = conditional, 'pw' = pairwise
% monkey_date       % experiment, used for saving
% signalType                % 'lfp' or 'spikes'
% domain = 'SD';                      % 'SD' = spectral, 'TD' = time domain, 'TDbySum' = spectral then sum over frequencies
% channelsToUse  % superficial ; mid ; deep - change all depending on experiment
% demeanTrialAvg                 % 0 = do not demean data by trial avg, 1 = do so
% axisLimit                     % if 0, axisLimit = maxGC (only used for subtractorExtractor)


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
outTarg_SaccFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,demeaned];
eval(['mkdir ',outTarg_SaccFolderName]);
performMVGC;
saveas(figure(66), [outTarg_SaccFolderName,'/',outTarg_SaccFileString]);
clf 
close all
save([outTarg_SaccFolderName,'/',outTarg_SaccFileString]);

% saccade, in - out
disp('...')
disp('saccade, in - out')
inTargVal = 42;
inTargString = getInTargString(inTargVal);
inMinusOutTarg_SaccFolderString = ['FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/IndividualCues/',cueType];
inMinusOutTarg_SaccFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,demeaned];
eval(['mkdir ',inMinusOutTarg_SaccFolderString]);
inTargFileString = [inTarg_SaccFolderName,'/',inTarg_SaccFileString];
outTargFileString = [outTarg_SaccFolderName,'/',outTarg_SaccFileString];
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
inTarg_TargFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,demeaned];
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
outTarg_TargFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,demeaned];
eval(['mkdir ',outTarg_TargFolderName]);
performMVGC;
saveas(figure(66), [outTarg_TargFolderName,'/',outTarg_TargFileString]);
clf 
close all
save([outTarg_TargFolderName,'/',outTarg_TargFileString]);

% target, in - out
disp('...')
disp('target, in - out')
inTargVal = 42;
inTargString = getInTargString(inTargVal);
inMinusOutTarg_TargFolderString = ['FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/IndividualCues/',cueType];
inMinusOutTarg_TargFileString = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',cueType,'_',inTargString,demeaned];
eval(['mkdir ',inMinusOutTarg_TargFolderString]);
inTargFileString = [inTarg_TargFolderName,'/',inTarg_TargFileString];
outTargFileString = [outTarg_TargFolderName,'/',outTarg_TargFileString];
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
        axisLimitString = '1';
    case 'TD'
        axisLimit = 0.2;
        axisLimitString = '0p2';
    case 'TDBySum'
        axisLimit = 1500;
        axisLimitString = '1500';
    otherwise
        axisLimit = 0;
        axisLimitString = '0';
end
firstAxisLimitFolderString = ['FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/CombinedCues/',axisLimitString];
eval(['mkdir ',firstAxisLimitFolderString]);

% combined figures, intarg, axisLimit = 1
disp('...')
disp(['intarg, max axis GC = ', axisLimitString])
saccFileString = inTarg_SaccFileString; % Or whatever the name is in the script
targFileString = inTarg_TargFileString;
performCombinedPlot;
inTargString = getInTargString(1);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimitString];
saveas(figure(66), [firstAxisLimitFolderString,'/',fileName]);
saveas(figure(66), [firstAxisLimitFolderString,'/',fileName], 'tif');
clf
close all

% combined figures, outtarg, axisLimit = 1
disp('...')
disp(['outtarg, max axis GC = ', axisLimitString])
saccFileString = outTarg_SaccFileString;
targFileString = outTarg_TargFileString;
performCombinedPlot;
inTargString = getInTargString(0);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimitString];
saveas(figure(66), [firstAxisLimitFolderString,'/',fileName]);
saveas(figure(66), [firstAxisLimitFolderString,'/',fileName], 'tif');
clf
close all

% combined figures, in-out, axisLimit = 1
disp('...')
disp(['in-out, max axis GC = ', axisLimitString])
saccFileString = inMinusOutTarg_SaccFileString;
targFileString = inMinusOutTarg_TargFileString;
performCombinedPlot;
inTargString = getInTargString(42);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimitString];
saveas(figure(66), [firstAxisLimitFolderString,'/',fileName]);
saveas(figure(66), [firstAxisLimitFolderString,'/',fileName], 'tif');
clf 
close all



% create axisLimit = 0.5 folder
switch domain
    case 'SD'
        axisLimit = 0.5;
        axisLimitString = '0p5';
    case 'TD'
        axisLimit = 0.1;
        axisLimitString = '0p1';
    case 'TDBySum'
        axisLimit = 700;
        axisLimitString = '700';
    otherwise
        axisLimit = 0;
        axisLimitString = '0';
end
secondAxisLimitFolderString = ['FiguresAndResults/',analysisType,'/',monkey_date,'/',domain,'/',signalType,'/CombinedCues/',axisLimitString];
eval(['mkdir ',secondAxisLimitFolderString]);

% combined figures, intarg, axisLimit = 0.5
disp('...')
disp(['intarg, max axis GC = ', axisLimitString])
saccFileString = inTarg_SaccFileString;
targFileString = inTarg_TargFileString;
performCombinedPlot;
inTargString = getInTargString(1);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimitString];
saveas(figure(66), [secondAxisLimitFolderString,'/',fileName]);
saveas(figure(66), [secondAxisLimitFolderString,'/',fileName], 'tif');
clf
close all

% combined figures, outtarg, axisLimit = 0.5
disp('...')
disp(['outtarg, max axis GC = ', axisLimitString])
saccFileString = outTarg_SaccFileString;
targFileString = outTarg_TargFileString;
performCombinedPlot;
inTargString = getInTargString(0);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimitString];
saveas(figure(66), [secondAxisLimitFolderString,'/',fileName]);
saveas(figure(66), [secondAxisLimitFolderString,'/',fileName], 'tif');
clf
close all

% combined figures, in-out, axisLimit = 0.5
disp('...')
disp(['in-out, max axis GC = ', axisLimitString])
saccFileString = inMinusOutTarg_SaccFileString;
targFileString = inMinusOutTarg_TargFileString;
performCombinedPlot;
inTargString = getInTargString(42);
fileName = [analysisType,'_',monkey_date,'_',domain,'_',signalType,'_',inTargString,'_',demeaned,axisLimitString];
saveas(figure(66), [secondAxisLimitFolderString,'/',fileName]);
saveas(figure(66), [secondAxisLimitFolderString,'/',fileName], 'tif');
clf
close all