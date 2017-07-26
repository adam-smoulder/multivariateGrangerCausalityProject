% performs MVGC based on domain

if  strcmp(domain, 'SD')
    condMVGC_SD; % perform spectral-domain MVGC
elseif strcmp(domain, 'TD')
    condMVGC_TD; % perform time-domain MVGC
elseif strcmp(domain,'TDBySum')
    condMVGC_TDBySum; % perform spectral-domain MVGC then sum over frequencies
else
    ME = MException('MyComponent:noSuchVariable','%s is not a domain type (SD, TD, TDBySum)',domain);
        throw(ME)
end