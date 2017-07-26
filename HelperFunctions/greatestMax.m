function [ maxOfMaxes ] = greatestMax( matrix )
% greatestMax finds the maximum over all dimensions of a matrix 
%   matrix = your input matrix; can be as many dimensions as desired
%   maxOfMaxes = the highest single value in matrix

% for some odd reason, if you make this 1 it gets stuck...
% this works, though I'm not sure why we need to do it this way.
while length(size(matrix)) > 2
    matrix = squeeze(max(matrix));
end

maxOfMaxes = max(max(matrix));

