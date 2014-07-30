function [map pval] = correctMap(map,winSz,thresh,pval)

% function [map pval] = correctMap(map,winSz,thresh,pval)
% 
% 2d pixel normalization.
% Implements method by Tolias et al. 2006
%
% PHB 2009-06-01

if nargin < 4
  pval = 0.05;
end

if nargin < 3
  thresh = 17;
end

if nargin < 2
  winSz = 5;
end

% Implements method by Tolias et al. 2006
win = ones(winSz);
mask = filter2(win,map) <= thresh;
map(mask) = 0;

if nargout>1
  pval = 1-binocdf(thresh,winSz^2,pval);
end
