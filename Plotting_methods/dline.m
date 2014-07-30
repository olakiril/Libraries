function dline

% function dline
% 
% creates a diagonal line and equalizes the ranges

la = get(gca,'children');
X =  get(la,'XData');
Y =  get(la,'YData');

if iscell(X)
    X = [X{:}];
    Y = [Y{:}];
end

mx = max([X(:);Y(:)]);
mn = min([X(:);Y(:)]);

xlim([mn mx])
ylim([mn mx])

hold on
plot([mn mx],[mn mx],'-.','color',[0.6 0.6 0.6])
hold off

axis square

