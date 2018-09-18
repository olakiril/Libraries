function imgrid(varargin)

params.linewidth = 1;
params.colors = [0.6 0.6 0.6;0 0 0];

params = getParams(params,varargin);

ax = gca;
hold on

xtick = get(ax,'xtick');
ytick = get(ax,'ytick');
xl = get(ax,'xlim');
yl = get(ax,'ylim');

for k = ytick
    x = xl;
    y = [k k];
    plot(x,y,'Color',params.colors(1,:),'LineStyle','-','linewidth',params.linewidth);
    plot(x,y,'Color',params.colors(2,:),'LineStyle',':','linewidth',params.linewidth);
end

for k = xtick
    x = [k k];
    y = yl;
    plot(x,y,'Color',params.colors(1,:),'LineStyle','-','linewidth',params.linewidth);
    plot(x,y,'Color',params.colors(2,:),'LineStyle',':','linewidth',params.linewidth);
end

hold off