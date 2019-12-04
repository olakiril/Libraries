function [regOUT, pOUT, rOUT, ahOUT]= regressPlot(b,a,varargin)

% function regressPlot(a,b,varargin)
%
% does the regression analaysis. Bun also gives correlation results.
%
% MF 2009-04-30

params.plot = 1;
params.thr = 0.05;
params.midline = 0;
params.names = [{''},{''}];
params.barplot = 0;
params.constrict = [];
params.fontsize = 9;
params.extrabars = []; % [means ;ers]
params.color = [0 0 0];
params.title = '';
params.boxplot = 0;
params.MarkerSize = 2;
params.MarkerType = 'O';
params.MarkerEdgeColor = 'none';
params.MarkerFaceColor = [0.5 0.5 0.5];
params.figure = [];
params.textcolor = [0 0 0];
params.linecolor = [0 0 0];
params.stat2title = 0;
params.linewidth = 1;
params.method = 'regress';
params.globalcolor = [];
params.linetype = '-';
params.boxcolor = [0.5 0.5 1];

params = getParams(params,varargin);


if ~isempty(params.globalcolor)
    params.color = params.globalcolor;
    params.MarkerEdgeColor = params.globalcolor;
    params.MarkerFaceColor = params.globalcolor;
    params.textcolor = hsv2rgb(rgb2hsv(params.globalcolor).*[1 0.8 0.7]);
    params.linecolor = hsv2rgb(rgb2hsv(params.globalcolor).*[1 0.8 0.7]);
    params.boxcolor = params.globalcolor;
end

if params.plot && isempty(params.figure)
    fh = figure;
    if iscell(params.title)
        set(fh,'Name',cell2mat(reshape(params.title,1,[])))
    else
        set(fh,'Name',params.title)
    end
elseif ~isempty(params.figure)
     figure(params.figure)
end

if size(a,1)>size(a,2)
    a = a';
end

if size(b,1)>size(b,2)
    b = b';
end

if ~isempty(params.constrict)
    i = a<prctile(a,params.constrict(1,2)) & a>prctile(a,params.constrict(2,2)) & b<prctile(b,params.constrict(1,1)) & b>prctile(b,params.constrict(2,1));
    a = a(i);
    b = b(i);
end

[reg,~,~,~,stats] = regress(a',[ones(size(b))' b']);
reg = reg';
[c, pc] = corr(a',b');

if strcmp(params.method,'corr')
    r = c;
    p = pc;
    type = 'R';
else
    r = stats(1);
    p = stats(3);
    type = 'R^2';
end

if params.plot
   
    plot(b,a,params.MarkerType,'MarkerSize',params.MarkerSize,...
        'Color',params.color,'markeredgecolor',params.MarkerEdgeColor,...
        'markerFacecolor',params.MarkerFaceColor);
    ah(1) = gca;
    hold on
    AxisPro = axis;
    Yscale = AxisPro(4)-AxisPro(3);
    Xscale = AxisPro(2)-AxisPro(1);
    if p<params.thr
        data = [nanmin(b)-std(b)/2 nanmax(b)+std(b)/2];
        plot (data,reg(1) + reg(2)*data,params.linetype,'color',params.linecolor,'LineWidth',params.linewidth);
        if ~params.stat2title
            tex{1} = [type ' : ' num2str(round(r*100)/100)];
            tex{2} = ['p < ' num2str(params.thr)];
        else
            params.title = ([type ' : ' num2str(round(r*100)/100) ' p < ' num2str(params.thr)]);
        end
    else
        tex{1} = '';
        tex{2} = '';
    end
    htext(1) = text((AxisPro(1)+(Xscale*1)/12),(AxisPro(3)+(Yscale*9)/12),tex{1},'color',params.textcolor,'FontSize',params.fontsize);
    htext(2) = text((AxisPro(1)+(Xscale*1)/12),(AxisPro(3)+(Yscale*8)/12),tex{2} ,'color',params.textcolor,'FontSize',params.fontsize);
    
    if params.midline
        maxV = nanmax([a b]);
        plot ([0 maxV],[0 maxV],'--','Color',[0.7 0.7 0.7])
        set(gca,'XLim',[0 maxV])
        set(gca,'YLim',[0 maxV])
        axis square
%     else
%         xlim([nanmin(b)-nanstd(b) nanmax(b)+nanstd(b)]);
%         ylim([nanmin(a)-nanstd(a) nanmax(a)+nanstd(a)]);
    end
    set(gca,'FontSize',params.fontsize)
    set (gcf,'Color',[ 1 1 1])
    set(gca,'Box','off')
    ylabel(params.names{2});
    xlabel(params.names{1});
    t = title(params.title);
    set(t,'fontsize',params.fontsize+2,'fontweight','bold')
    
    if isempty(params.figure)
        % fix figure
        axis square
        pos = get(gcf,'position');
        set(gcf,'position',[pos(1) pos(2)*0.8 pos(4) pos(4)])
        pos = get(gca,'position');
        set(gca,'position',[pos(1)*1.4 pos(2)*1.4 pos(3)*0.85 pos(4)*0.85]);
        xlabh = get(gca,'XLabel');
        pos = get(xlabh,'Position');
        %set(xlabh,'Position',[pos(1) pos(2)*1.15 pos(3)])
        xlabh = get(gca,'YLabel');
        pos = get(xlabh,'Position');
        set(xlabh,'Position',[pos(1)*1.1 pos(2) pos(3)])
    end
  
    if params.boxplot
        x_lim = get(gca,'xlim');
         y_lim = get(gca,'ylim');
         xticks = get(gca,'xtick');
         yticks = get(gca,'ytick');
          xticklabels = get(gca,'xticklabel');
         yticklabels = get(gca,'yticklabel');

        hold on
        boxplot(a,'positions',diff(x_lim)*0.04+x_lim(1),'plotstyle','compact',...
            'medianstyle','target','labels',{''},'jitter',0,'colors',params.boxcolor)
        hold on
        boxplot(b,'positions',diff(y_lim)*0.04+y_lim(1),'plotstyle','compact',...
            'orientation','horizontal','medianstyle','target','labels',{''},'jitter',0,'colors',params.boxcolor)
        xlim(x_lim)
        ylim(y_lim)
        set(gca,'xtick',xticks,'ytick',yticks,'xticklabel',xticklabels,'yticklabel',yticklabels)
        grid on
    end
else
    [~,p] = ttest(b,a,params.thr);
end

if nargout>0
    regOUT = reg;
    pOUT = p;
    rOUT = c;
    if params.plot
        ahOUT.axis = ah;
        ahOUT.text = htext;
        ahOUT.figure = fh;
    end
end
