function [p W] = circ_homoTest(varargin)

% function [p W] = circ_homoTest(varargin)
%
% test whether two or more distributions are identical
% (from: statistical analysis of circular data by Fisher)
%
% MF 2009-08-14

% get the ranked values of the angles
rankedAngles = cell(1,length(varargin));
[rankedAngles{1:length(varargin)}] = circ_rank(varargin);

% find C & S
C = zeros(1,length(varargin));
S = zeros(1,length(varargin));

for i = 1:length(varargin)
    C(i) = sum(cos(rankedAngles{i}));
    S(i) = sum(sin(rankedAngles{i}));
end
    
% test statistic
W = 2*sum((C.^2  + S.^2)./cellfun(@length,varargin));

% p stat
p=1-chi2cdf(W,2);

