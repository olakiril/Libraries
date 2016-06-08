function savefigures(type,figH,nofig)

% function savefigures
%
% saves all the open figures in png and fig format
%
% MF 2011-08-23

if isa(type,'matlab.ui.Figure')
    figH = type;
end

if nargin<2 && ~isa(type,'matlab.ui.Figure')
    figH = findobj('type','figure');
end

if ~nargin || isa(type,'matlab.ui.Figure')
    type = '-dpng';
else
    if ~isnumeric(type)
        nofig = 1;
    end
end

for ifig = 1:length(figH)
    
    name = get(figH(ifig),'Name');
    
    if isempty(name)
        name = num2str(ifig);
    end
    name(strfind(name,':')) = '';
    name(strfind(name,'"')) = '';

    set(figH(ifig),'PaperPositionMode','auto')

    saveas(figH(ifig),name,type)
%     print(figH(ifig),type,name)
    if ~ exist('nofig','var')
        saveas(figH(ifig),name,'fig')
    end
end