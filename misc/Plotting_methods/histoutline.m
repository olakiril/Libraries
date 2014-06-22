function hOut = histoutline(xx, num, varargin)
% Plot a histogram outline.
% h = HISTOUTLINE(xx, num, varargin) Plot a histogram outline.
%
% HISTOUTLINE uses hist to do most of the work:
%
% HISTOUTLINE(...) produces a plot of the outline of the histogram of the
% results.
%
% Example:
%     data = randn(100, 1);
%     histoutline(data, 50);
%
% See also HIST, HISTC, MODE.
%
% Matt Foster <ee1mpf@bath.ac.uk>

if nargin < 1
    error('No input given');
end

% Default to standard number of histogram bins.
if nargin < 2
    num = 10;
end

p.area = 1;
p.color = [0 0 1];
p.alpha = 0.5;

% update parameters if supplied
for i = 1:2:length(varargin);p.(varargin{i}) = varargin{i+1};end


[n,x] = hist(xx, num);

if p.area
    [xx,yy] = stairs(x, n);
    step = max(diff(xx));
    xx(end+1:end+2) = [xx(end)+step; xx(end)+step];
    xx = [xx(1);xx(1);xx];
    yy(end+1:end+2) = [yy(end);0];
    yy = [0;yy(1);yy];
    h = patch(xx,yy,p.color,'facealpha',p.alpha,'edgecolor','none');

else
    h = stairs(x, n, varargin{:});
end

if nargout
    hOut = h;
end