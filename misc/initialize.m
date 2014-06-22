function varargout = initialize(type,varargin)

% function varargout = initiate(type,size)
% 
% initiates the requested variables to the preffered type & size
%
% MF 2012-03

size = cell2mat(varargin);

for ivar = 1:nargout
    s = sprintf('%d,',size);
    eval(['varargout{ivar} =  ' type '(' s(1:end-1) ');']);
end