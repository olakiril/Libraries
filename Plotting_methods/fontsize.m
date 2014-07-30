function fontsize(sz)

% function fontsize
%
% Changes all fontsizes 
%
% MF 2011-10-20

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
        fontchange(figchildren(ifigchild),sz);
        
    end
end

function fontchange(ax,sz)

%Get all subplots
children = get(ax,'Children');

%loop through all children and find texts
for ichild = 1:length(children)
    if strcmp(get(children(ichild),'Type'),'text')
        fixtxt(children(ichild),sz);
    end
end

% change axis labels
fixtxt(get(ax,'XLabel'),sz);
fixtxt(get(ax,'YLabel'),sz);

% change axis ticklabels
set(ax,'FontSize',sz);

% change title
set(get(ax,'Title'),'FontSize',sz);

function ax = fixtxt(ax,sz)

txt = get(ax,'String');
if isempty(txt);return;end;
set(ax,'FontSize',sz);