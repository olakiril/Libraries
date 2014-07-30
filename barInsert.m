function barInsert(b,a,varargin)

params.thr = 0.05;
params.fontsize = 18;
params.extrabars = []; % [means ;ers]
params.markersize = 0.5;
params.names = [];
params.insert = 1;
params.angle = 45;
params.space = 1.2;

params = getParams(params,varargin);

if params.insert
    % set up new figure
    ah(2) =  createInsetAxis(gca);
end

eb = params.extrabars;
m1 = mean(b);
m2 = mean(a);
er1 = std(b)/sqrt(length(b));
er2 = std(a)/sqrt(length(a));
if ~isempty(eb)
    bar([m1 m2 eb(1,:)], 0.6,'k','edgecolor','k', 'linewidth', 1);
else
    bar([m1 m2], 0.6,'k','edgecolor','k', 'linewidth', 1);
end

hold on
if ~isempty(eb)
    errorbar(1:2+size(eb,2), [m1 m2 eb(1,:)],[er1 er2 eb(2,:)], 'k', 'linestyle', 'none', 'linewidth', 2);
    l = 4;
else
    errorbar(1:2, [m1 m2],[er1 er2], 'k', 'linestyle', 'none', 'linewidth', 2);
    l = 2;
end
[s p] = ttest2(b,a,params.thr);
erl = max([er1 er2])*5;
mx = max([m2 m1])*params.space + erl;
if s == 1
    plot([1 1 2 2],[m1 + erl,mx ,mx,m2 + erl],'k');
    text(1.5, mx*params.space,['p < ' num2str(params.thr)],...
        'FontSize',params.fontsize,'HorizontalAlignment','center')
end
set(gca,'Box','Off');
set(gca,'YLim',[0  mx*params.space])
set(gca,'Xlim',[0 l+1])
set(gca,'FontSize',params.fontsize);
set(gca,'XTickLabel',params.names)
if ~isempty(params.names)
    ht = xticklabel_rotate([],params.angle);
    set(ht,'HorizontalAlignment','right')
end


