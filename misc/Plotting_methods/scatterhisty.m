function scatterhisty(a,b,varargin)

params.regress = 1;
params.thr = 0.05;
params.names = [{''},{''}];
params.fontsize = 13;
params.color = [0 0 0];
params.title = '';
params.MarkerSize = 1;
params.MarkerType = 'O';
params.MarkerEdgeColor = [0 0 0];
params.MarkerFaceColor = [0 0 0];
params.bins = 20;
params.EdgeColor = [0 0 0];
params.FaceColor = [0.5 0.5 0.5];

params = getParams(params,varargin);

figure

a = reshape(a,1,[]);
b = reshape(b,1,[]);

h = scatterhist(a,b,'Direction','out','NBins',[params.bins params.bins]);

% hold(h(1),'on')
set(h(1),'Position',[0.35 0.15 0.55 0.75]);
set(gcf,'Color',[1 1 1])
set(get(h(1),'Children'),'Color',[0.3 0.3 0.3],'Marker',params.MarkerType,'MarkerSize',params.MarkerSize,...
    'Color',params.color,'markeredgecolor',params.MarkerEdgeColor,...
    'markerFacecolor',params.MarkerFaceColor);

[r p] = corr(b',a','type','Spearman');
reg = regress(b',[ones(size(a))' a'])';
hold on
AxisPro = axis(h(1));
Yscale = AxisPro(4)-AxisPro(3);
Xscale = AxisPro(2)-AxisPro(1);
if p < params.thr && params.regress
    plot (a,reg(1) + reg(2)*a,'r','LineWidth',2);
    text((AxisPro(1)+(Xscale*9)/12),(AxisPro(3)+(Yscale*6)/12),['r : ' num2str(round(r*100)/100)],'color',[0 0 1],'FontSize',params.fontsize);
    text((AxisPro(1)+(Xscale*9)/12),(AxisPro(3)+(Yscale*5)/12),['p < ' num2str(params.thr)] ,'color',[0 0 1],'FontSize',params.fontsize);
end
set(gca,'FontSize',params.fontsize)
set (gcf,'Color',[ 1 1 1])
set(gca,'Box','off')
ylabel(params.names{2});
xlabel(params.names{1});
title(params.title)

set(get(h(3),'Children'),'EdgeColor',params.EdgeColor,'FaceColor',params.FaceColor);
hold(h(3),'on')
mx = min(get(get(h(3),'Children'),'Ydata'));
plot([mx*1.2 0],[mean(b) mean(b)],'-.r','LineWidth',2,'Parent',h(3))

text(mx*1.1,mean(b)*1.03,num2str(roundall(mean(b),0.01)),'color',[0 0 0.5],...
    'FontSize',params.fontsize,'Parent',h(3),'rotation',90,'VerticalAlignment','Top','HorizontalAlignment','Left');
delete(h(2))
% set(get(h(2),'Children'),'Visible','off')