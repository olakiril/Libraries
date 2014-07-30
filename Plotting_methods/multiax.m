function multiax(varargin)

% function multiax
%
% sets axes propertis on all figures
%
% MF 2011-11-29

if isempty(varargin);return;end

params = [];
params = getParams(params,varargin);

figH = findobj('type','figure');

%loop through all figures
for ifig = 1:length(figH)
    
    set(0,'CurrentFigure',figH(ifig))
    
    %Get all figures
    figchildren = get(figH(ifig),'Children');
    
    %loop through all subplots
    for ifigchild = 1:length(figchildren)
        
        set(figH(ifig),'CurrentAxes',figchildren(ifigchild))
        ax = figchildren(ifigchild);
        % do it
        flds = fields(params);
        for ipar = 1:length(flds)
            
            set(ax,flds{ipar},eval(['params.' flds{ipar}]))
            
            %Get all subplots
            children = get(ax,'Children');
            
            %loop through all children and find texts
            for ichild = 1:length(children)
                if strcmp(get(children(ichild),'Type'),'text')
                      set(children(ichild),flds{ipar},eval(['params.' flds{ipar}]))
                end
            end
            
            % change axis labels
            set(get(ax,'XLabel'),flds{ipar},eval(['params.' flds{ipar}]))
            set(get(ax,'YLabel'),flds{ipar},eval(['params.' flds{ipar}]))
            
            % change title
            set(get(ax,'Title'),flds{ipar},eval(['params.' flds{ipar}]))
            
        end
    end
end


