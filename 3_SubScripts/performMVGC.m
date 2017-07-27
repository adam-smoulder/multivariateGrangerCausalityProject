% performs MVGC based on domain

if  strcmp(analysisType, 'cond')
    condMVGC;
% elseif strcmp(analysisType, 'pw')
%     pwMVGC;
else
    ME = MException('MyComponent:noSuchVariable','%s analysis is not implemented',analysisType);
        throw(ME)
end
