function [ inTargString ] = getInTargString( inTargVal )
%getInTargString returns the inTargString from the given inTargVal
%   cueType: 0 = outtarg, 1 = intarg, anything else is all data

switch inTargVal
    case 0
        inTargString = 'outtarg';
    case 1
        inTargString = 'intarg';
    otherwise
        inTargString = 'inAndOuttarg';
end
end


