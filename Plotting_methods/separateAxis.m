function separateAxis(ticksize)

set(gcf,'color',[1 1 1])
fz = get(gca,'FontSize');
xtick = get(gca,'xtick');
xlabels = get(gca,'xticklabel');
xl = get(gca,'xlim');
pos = get(gca,'Position');
ytick = get(gca,'ytick');
ylabels = get(gca,'yticklabel');
yl = get(gca,'ylim');
axis off
hold on
plot([xtick(1) xtick(end)],[yl(1) yl(1)],'k')
plot([xl(1) xl(1)],[ytick(1) ytick(end)],'k')
nposXx = (xtick-xl(1))/(xl(2)-xl(1));
nposXy = -0.02;
nposYy = (ytick-yl(1))/(yl(2)-yl(1));
nposYx = -0.02;

if nargin<1
    ticksize = 0.05;
end

for i = 1:length(xlabels)
    annotation('line',[nposXx(i) nposXx(i)]*(pos(3))+pos(1),[pos(2) pos(2)+pos(2)*ticksize])
    text(nposXx(i),nposXy,xlabels(i),'units','normalized','horizontalalignment','center',...
        'verticalalignment','top','fontsize',fz)
end

for i = 1:length(ylabels)
    annotation('line',[pos(1) pos(1)+pos(1)*ticksize],[nposYy(i) nposYy(i)]*(pos(4))+pos(2))
    text(nposYx,nposYy(i),ylabels(i),'units','normalized','horizontalalignment','right',...
        'verticalalignment','middle','fontsize',fz)   
end
