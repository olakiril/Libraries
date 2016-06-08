function fontcolor(color)

% function fontsize
%
% Changes all fontsizes 
%
% MF 2016-04

figH = findobj('type','figure');

%loop through all figures
for ifig = 1:length(figH)
    
    set(0,'CurrentFigure',figH(ifig));
    
    %Get all figures
    figchildren = get(figH(ifig),'Children');
    
    %loop through all subplots
    for ifigchild = 1:length(figchildren)
        
        set(figH(ifig),'CurrentAxes',figchildren(ifigchild));
        
        % do it
        fontchange(figchildren(ifigchild),color);
        
    end
end

function fontchange(ax,color)

%Get all subplots
children = get(ax,'Children');

%loop through all children and find texts
for ichild = 1:length(children)
    if strcmp(get(children(ichild),'Type'),'text')
        fixtxt(children(ichild),color);
    end
end

% change axis labels
fixtxt(get(ax,'XLabel'),color);
fixtxt(get(ax,'YLabel'),color);

% change axis ticklabels
set(ax,'FontColor',color);

% change title
set(get(ax,'Title'),'Fontcolor',color);

function ax = fixtxt(ax,color)

txt = get(ax,'String');
if isempty(txt);return;end;
set(ax,'Fontcolor',color);