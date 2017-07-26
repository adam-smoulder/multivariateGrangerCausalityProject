% perform GC subtraction selects which subtraction to do based on domain
if  strcmp(domain, 'SD')
    subtractorExtractor_SD; % perform spectral-domain MVGC
elseif strcmp(domain, 'TD') || strcmp(domain,'TDBySum') 
    subtractorExtractor_TD; % perform time-domain MVGC
else
    ME = MException('MyComponent:noSuchVariable','%s is not a domain type (SD, TD, TDBySum)',domain);
        throw(ME)
end
