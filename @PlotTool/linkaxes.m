function linkaxes(hdls,varargin)
% Extends linkaxes built-in
%   by automatically determining axis limits such that the maxima across
%   all axes are used instead of the limits of the first.
%
%   linkaxes(hdls)
%   linkaxes(hdls,what) where what can be 'x', 'y', 'xy', or 'off'. Default
%   is 'xy'.
%
% AE 2008-09-29

% catch single axis input
if isscalar(hdls)
    return
end

% deal with single-input case
if nargin >= 2
    what = varargin{1};
else
    what = 'xy';
end

% first determine maximum limits
if any(what == 'x')
    xl = get(hdls,'xlim');
    xl = cat(1,xl{:});
    xl = [min(xl(:,1)),max(xl(:,2))];
end
if any(what == 'y')
    yl = get(hdls,'ylim');
    yl = cat(1,yl{:});
    yl = [min(yl(:,1)),max(yl(:,2))];
end

% link axes
linkaxes(hdls,what);

% now set maximum limits
if any(what == 'x')
    set(hdls(1),'xlim',xl);
end
if any(what == 'y')
    set(hdls(1),'ylim',yl);
end
