function latex

% function latex
%
% converts all figures interpreter to latex
%
% MF 2011-09-03

figH = findobj('type','figure');

%loop through all figures
for ifig = 1:length(figH)
    
    set(0,'CurrentFigure',figH(ifig))
    
    %Get all figures
    figchildren = get(figH(ifig),'Children');
    
    %loop through all subplots
    for ifigchild = 1:length(figchildren)
        
        set(figH(ifig),'CurrentAxes',figchildren(ifigchild))
        
        % do it
        lax(figchildren(ifigchild))
        
    end
end

function lax(ax)

%Get all subplots
children = get(ax,'Children');

%loop through all children and find texts
for ichild = 1:length(children)
    if strcmp(get(children(ichild),'Type'),'text')
        fixlax(children(ichild));
    end
end

% change axis labels
xlp = get(get(ax,'XLabel'),'Position');
set(fixlax(get(ax,'XLabel')),'Interpreter','Latex','Position',xlp);
ylp = get(get(ax,'YLabel'),'Position');
set(fixlax(get(ax,'YLabel')),'Interpreter','Latex','Position',ylp);

% change axis ticklabels
xt = get(ax,'XTick'); xtl = get(ax,'XTickLabel');
yt = get(ax,'YTick'); ytl = get(ax,'YTickLabel');
fs = get(ax,'FontSize');
set(ax,'XTickLabel',repmat(' ',length(xt),1));set(ax,'YTickLabel',repmat(' ',1,length(yt)));
xl = get(ax,'Xlim'); yl = get(ax,'Ylim');
if ~isempty(xt) && ~isempty(xtl)
    text(xt,repmat(yl(1) - (yl(2) - yl(1))*0.02,size(xt)),xtl,'FontSize',fs,...
        'interpreter','latex','HorizontalAlignment','center','VerticalAlignment','top')
    if round(log10(nanmean(xt./str2num(xtl)')))~= 0 %#ok<ST2NM>
        text(xl(2)+ (xl(2)-xl(1))*0.05,yl(1) - (yl(2) - yl(1))*0.05,['$ 10^{' num2str(round(log10(nanmean(xt./str2num(xtl)')))) '} $'],'FontSize',fs,...
            'interpreter','latex','HorizontalAlignment','center','VerticalAlignment','top') %#ok<ST2NM>
    end
end
if ~isempty(yt) && ~isempty(ytl)
    text(repmat(xl(1) - (xl(2) - xl(1))*0.02,size(yt)),yt,ytl,'FontSize',fs,...
        'interpreter','latex','HorizontalAlignment','right','VerticalAlignment','middle')
    if round(log10(nanmean(yt./str2num(ytl)')))~= 0 %#ok<ST2NM>
        text(xl(1) - (xl(2) - xl(1))*0.05,yl(2) + (yl(2)-yl(1))*0.05,['$ 10^{' num2str(round(log10(nanmean(yt./str2num(ytl)')))) '} $'],'FontSize',fs,...
            'interpreter','latex','HorizontalAlignment','right','VerticalAlignment','middle') %#ok<ST2NM>
    end
end

% change title
tp = get(get(ax,'Title'),'Position');
set(get(ax,'Title'),'Interpreter','Latex','Position',tp);

function ax = fixlax(ax)

txt = get(ax,'String');
if isempty(txt);return;end;
name = [];
for iRow = 1:size(txt,1)
    T = txt(iRow,:);
    % translate some symbols
    lt = strfind( T,'<');
    if lt
        T = [T(1:lt-1) '\textless\' T(lt+1:end)];
    end
    lt = strfind( T,'>');
    if lt
         T = [T(1:lt-1) '\textmore\' T(lt+1:end)];
    end
    lt = strfind( T,'#');
    if lt
         T = [T(1:lt-1) '\#' T(lt+1:end)];
    end
    name = strvcat(name,T); %#ok<VCAT>
end
txt = name;
set(ax,'String',txt,'Interpreter','Latex')