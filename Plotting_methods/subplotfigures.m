function subplotfigures(varargin)

% function subplotfigures
%
% puts all figures in subplots
%
% MF 2011-10-20

params.subplot = [];
params.index = [];
params.name = 'Overview';

params = getParams(params,varargin);

figH = findobj('type','figure');
figH = sort(figH);
figO = figure;
clf
set(figO,'Name',params.name);

if ~isempty(params.subplot)
    x = params.subplot(1);
    y = params.subplot(2);
else
    x = ceil(sqrt(length(figH)));
    y = ceil(length(figH)/x);
end

if ~isempty(params.index)
    index = params.index;
else
    index = 1:length(figH);
end

for fig = 1:length(index)
    ifig = index(fig);
    name = get(figH(ifig),'Name');
    set(0,'CurrentFigure',figH(ifig));
    ax = get(figH(ifig), 'Child');
    
    figure(figO);
    hold on
    sb = subplot(x,y,ifig);
    pos = get( sb, 'OuterPosition');
    delete(sb)
    
    for iax = length(ax):-1:1
        
        posax = get(ax(iax),'Position');
        set(ax(iax), 'Parent',figO)
        
        tpos(1) = posax(1)*pos(3) + pos(1);
        tpos(2) = posax(2)*pos(4) + pos(2);
        tpos(3) = posax(3)*pos(3)*0.7;
        tpos(4) = posax(4)*pos(4)*0.7;
        
        set(ax(iax), 'Position',tpos);
   
        if iax == length(ax)
            title(name);
        end
    end
    close(figH(ifig))
end

figure(figO)
suptitle(params.name)

set(gcf,'Color',[1 1 1])
fontsize(8)