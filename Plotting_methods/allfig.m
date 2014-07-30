function allfig(func)

% function allfig
%
% Applies the function to all the axes
%
% MF 2012-05-01

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
       func(figchildren(ifigchild));
        
    end
end
