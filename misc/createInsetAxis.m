function iah = createInsetAxis(mh,rect,varargin)
% function insetAxisHandle = createInsetAxis(mainAxisHandle,rect,param1,paramVal1,param2,paramVal2,...)
%-----------------------------------------------------------------------------------------
% CREATEINSETAXIS - Creates an inset axis for the given mainAxisHandle. The
% input 'rect' specifies [left bottom width height] data for inset relative to the
% mainAxis(not to the figure). 'rect' is optional.
%
% example: insetAxisHandle = createInsetAxis(124.21)
%          insetAxisHandle = createInsetAxis(mainAxisHandle,[0.7 0.7 0.2 0.2])
%          
% This function is called by:
% This function calls:
% MAT-files required:
%
% See also: 

% Author: Mani Subramaniyan
% Date created: 2010-09-08
% Last revision: 2010-09-08
% Created in Matlab version: 7.5.0.342 (R2007b)
%-----------------------------------------------------------------------------------------
if nargin < 2
    rect = [0.7 0.7 0.3 0.3];
end

unitType = get(mh,'Units');
if ~strcmpi(unitType,'normalized')
    set(mh,'Units','Normalized');
end

% Get the mainAxis position
pm = get(mh,'Position');

inL = pm(1)+rect(1)*pm(3); % Left
inB = pm(2)+rect(2)*pm(4); % Bottom
inW = pm(3)*rect(3); % Width
inH = pm(4)*rect(4); % Height

insetPos = [inL inB inW inH];
iah = axes('Position',insetPos);

% set(iah,'FontSize',maFs*0.75,'Box','Off','Units',unitType);
