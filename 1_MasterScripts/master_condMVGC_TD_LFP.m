%% Conditional MVGC Spectral Domain combined script for LFP-LFP interactions
% Last update: 7/27/17

% TODO: automate enlarge of final figures and save as tif, clean up variables

% To run this script, do the following:
% startup MVGC
% set channels to use accordingly
% ensure you're running MVGC with the correct parameters

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

masterMVGCScript
