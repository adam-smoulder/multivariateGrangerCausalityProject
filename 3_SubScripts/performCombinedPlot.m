% plots figures combining saccade and target cue data based on domain

if  strcmp(domain, 'SD')
    combinedCuePlot_SD; % perform spectral-domain plot
elseif strcmp(domain, 'TD') || strcmp(domain,'TDBySum')
    combinedCuePlot_TD; % perform time-domain plot
else
    ME = MException('MyComponent:noSuchVariable','%s is not a domain type (SD, TD, TDBySum)',domain);
        throw(ME)
end