function hOUT = halfPolar(phi,gain,varargin)
% HALFPOLAR function performs the polar plot in radian angle range [0 pi]
% using half polar coordinates
%
% HALFPOLAR(phi,gain) makes a plot with phi in radians angle range [0 pi]
% and gain in half polar coordinates. Phi and gain could be vector or matrix
% with the same dimensions. When Phi is a vector(1XN) and vector(1XN) and
% matrix(MXN)gain values are allowable. When Phi is a matrix(MXN) and then
% the gain should only be matrix(MXN) with the same row numbers.
%
% HALFPOLAR(phi,gain, linestyle) uses specified linestyle defined in cell
% variable linestyle to plot phi and gain, like: linestyle = {'ko-','b--'}
%
% HALFPOLAR(phi,gain, linestyle, xtickval) plots phi and gain with the
% prescribed tick value xtickval. like: xtickval = [15 25 45 75 105]
%
% Example:
% phi = linspace(0,pi,20);
% gain = 80 * rand(3,length(phi)) + 40;
% h = halfPolar(phi,gain,'linestyle',{'k-','g-.','r--','k-'},'xtickval',[30 40 65 80 95 120])
%
% See also polar;
%
% Tsinghua University, Beijing, China.
% MF 2012-03

if ~iscell(gain) && numel(gain)==length(gain)
    gain = {gain};
    phi = {phi};
else
    gain = mat2cell(gain,ones(1,size(gain,1)),size(gain,2));
    phi = mat2cell(phi,ones(1,size(phi,1)),size(phi,2));
end

phi = cellfun(@double,phi,'uniformoutput',0);
gain = cellfun(@double,gain,'uniformoutput',0);

max_gain = max(max([gain{:}]));
space_val = 6;
spoke_val = 6;
spoketickval = linspace(0,pi,spoke_val+1);

if nargin < 2
    error('Not enough input arguments.');
end

params.linestyle = {'.'};
params.xtickval = linspace(0 ,max_gain ,space_val);
params.xname = ' ';
params.mean = 1;
params.title = ' ';

params = getParams(params,varargin);

if params.mean && length(phi)<2
    phi{end+1} = [pi/2 mean(phi{1})];
     gain{end+1} = [0 mean(gain{1})];
     params.linestyle(2) = {'-r'};
end

linestyle = params.linestyle;
xtickval = params.xtickval;

% normalization the input value
gain_range = xtickval(end) - xtickval(1);   %obtain the gain range
gain_scale = cellfun(@(x) abs((x - xtickval(1)))/gain_range,gain,'uniformoutput',0); %[0,1]

cax = newplot;
tc = get(cax,'xcolor');
ls = get(cax,'gridlinestyle');

th = linspace(0,pi,200);
xunit = cos(th);
yunit = sin(th);

patch('xdata',xunit,'ydata',yunit, ...
    'edgecolor',tc,'facecolor',get(gca,'color'));

hold on;
m1 = length(phi);
m2 = length(gain);
if(m1 ~= m2)
    error('Matrix should be have the same dimension!');
else
    h = nan(m2,1);
    for i=1:m2
        x = gain_scale{i} .* cos(phi{i});
        y = gain_scale{i} .* sin(phi{i});
        h(i) = plot(x,y,linestyle{i},'linewidth',2);
    end
end

set(gca,'dataaspectratio',[1 1 1]);axis off;

hold on;
%define the circle
contour_val = abs((xtickval - xtickval(1))/gain_range);
for k=2:length(contour_val) %gain circles
    plot(xunit*contour_val(k), yunit*contour_val(k),ls,'color','black');
    text(contour_val(k),-0.05, sprintf('%.3g',xtickval(k)),'horiz', 'center', 'vert', 'middle');
    text(- contour_val(k),-0.05, sprintf('%.3g',xtickval(k)),'horiz', 'center', 'vert', 'middle');
end
text(contour_val(1),-0.05,sprintf('%.3g',xtickval(1)),'horiz', 'center', 'vert', 'middle');
text(-0.45,-0.15,params.xname);

%plot the spokes and  % annotate spokes in degrees
cst = cos(spoketickval);
snt = sin(spoketickval);
for k = 1:length(spoketickval) - 1
    plot(cst(k) * contour_val,snt(k) * contour_val,ls,'color',tc,'linewidth',1,...
        'handlevisibility','off');
    text(1.07*cst(k),1.07*snt(k),...
        sprintf('%.3g^{o}',spoketickval(k)/pi*180),...
        'horiz', 'center', 'vert', 'middle');
end
text(1.08*cst(end),1.07*snt(end),...
    sprintf('%.3g^{o}',spoketickval(end)/pi*180),...
    'horiz', 'center', 'vert', 'middle');
hold off;

t = title(params.title);
set(t,'position',[ 0 1.2  15])

if nargout>0
    hOUT = h;
end