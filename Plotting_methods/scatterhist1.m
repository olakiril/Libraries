function [hOUT, mOUT, pOUT] = scatterhist1(A,B,varargin)

% function scatterhist1(A,B,varargin)
%
% scatterhist1 gives a scatter plot of the two vectors and a histogram of
% their difference in which a significance student t-test is performed.
%
% MF 2011-09-01

% variable params
params.midlinecolor = [0.5 0.5 0.5];
params.midlinewidth = 1;
params.markersize = 4;
params.markertype = 'O';
params.MarkerEdgeColor = [0.2 0.2 0.2];
params.MarkerFaceColor = [0.2 0.2 0.2];
params.histcolor = [0.5 0.5 0.5];
params.histedgecolor = 'none';
params.difcolor = [1 0 0];
params.thr = 0.05;
params.names = [{''},{''}];
params.maxbin = 40;
params.title = '';
params.fontsize = 7;
params.diagtype = '-';
params.meantype = '-';
params.constrict = []; % take a % of the data.
params.heightgain = 5;
params.figure = [];
params.test = 'ttest';
params.reduce = 1.2;
params.ticks = [];
params.boxplot = false;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

if params.boxplot; params.reduce = params.reduce+0.2;end

% non variable size params
left_margin = 0.15;      % normalized left margin for scatter plot
bottom_margin = 0.15;    % normalized bottom margin for scatter plot
expansion = 0.5*(params.reduce^(1/3));         % normalized width and height of scatter plot

roundAll = @(x) round(x*10^abs(floor(log10(x))))/10^abs(floor(log10(x)));

% remove nans & infs
idx = ~isnan(A) & ~isnan(B) & ~isinf(A) & ~isinf(B);
A = A(idx);
B = B(idx);

% make sure vectors have the proper size and type
A = double(reshape(A,numel(A),1));
B = double(reshape(B,numel(B),1));

% remove outliers
if params.constrict
    uth = prctile([A(:);B(:)],params.constrict);
    lth = prctile([A(:);B(:)],100 - params.constrict);
    i = A < uth & A > lth ...
        & B < uth & B > lth;
    A = A(i);
    B = B(i);
end

% check if point of calling this function is to test the significance
if nargout>1
    hOUT = [];
    mOUT = mean(A - B);
    pOUT = ttest(A - B,0,params.thr);
    return
end

% create figure
if isempty(params.figure)
    f = figure;
    set(f,'Name',params.title,'position',[200,200,500,500])
else
    f = params.figure;
end
set(gcf,'Color',[1 1 1])

%% scatter plot
h = subplot(223);
plot(A,B,params.markertype,'markersize',params.markersize,...
    'MarkerEdgeColor',params.MarkerEdgeColor,'MarkerFaceColor',params.MarkerFaceColor);

mn = min([A; B]); mx = max([A; B]);
set(gca,'Xlim',[mn*params.reduce mx*params.reduce],'YLim',[mn*params.reduce mx*params.reduce]);
if params.ticks
    set(gca,'xtick',params.ticks,...
        'ytick',params.ticks);
end 
pos = get(h,'Position');
set(h,'Position',[pos(1),pos(2),...
    (pos(3) + pos(4))/2, (pos(3) + pos(4))/2],'box','off',...
    'FontSize',params.fontsize); % equalize axis
hold on
plot([mn*params.reduce mx*params.reduce],[mn*params.reduce mx*params.reduce],...
    params.diagtype,'Color',params.midlinecolor,'LineWidth',params.midlinewidth);

%% histogram
h(2) = subplot(222);
difrange = (max((A - B)) - min(A - B))*params.heightgain/(mx - mn);
bin = round(difrange*params.maxbin/(2*params.heightgain));
hist(A - B,bin);
cnt = hist(A - B,bin);
lim = get(h(2),'YLim');
set(gca,'XLim',[-max(abs(A - B)) max(abs(A - B))],...
    'YLim',[lim(1) lim(2)*(difrange)],'YColor',[1 1 1]);% equalize axis & reduce y axis
camorbit(45,0,'data',[0 0 1]);

%% get proper position
set(h(1),'position',[left_margin bottom_margin expansion expansion])
pos = get(h(1),'position');
w2 = 4 * max(abs(A - B)) * pos(3) / ((mx - mn) * 2);
set(h(2),'Position',[pos(1) + pos(3) - w2/4,...
    pos(2) + pos(4) - w2/4, w2/params.reduce, w2/params.reduce],...
    'YTick',round(max(cnt)/10)*10,'YTickLabel',[],'box','off','YAxisLocation','right',...
    'xtick',[],'ytick',[],'tickdir','out','xcolor',[1 1 1],'tickdir','in')


%% plot extra stuff on histogram
h(3) = findobj(gca,'Type','patch');
set(h(3),'FaceColor',params.histcolor,'EdgeColor',params.histedgecolor)
hold on;
plot([0 0],get(h(2),'YLim'),params.diagtype,'Color',params.midlinecolor,'LineWidth',params.midlinewidth) % midline
plot([mean(A - B) mean(A - B)],[0 max(cnt) * 1.2],params.meantype,'LineWidth',params.midlinewidth,...
    'color',params.difcolor) %diff
axis off
count = ceil(max(cnt)/2);
offset = max(cnt)/4;
textpos = max(A - B);
text(textpos,offset+count/2, num2str(count),...
    'FontSize',params.fontsize,'rotation',45,...
    'HorizontalAlignment','center','VerticalAlignment','top')
barpos = max(A - B)-0.01*(max(A - B)-min(A - B));
plot([barpos barpos],[offset offset+count],'color',[0 0 0])

%% mask the extra axis
plot([0 0],[max(cnt)*1.2 lim(2)*difrange],'Color',[1 1 1],'linewidth',4);
% plot([max((A - B))*1.03 max((A - B))*1.03],[0 max(cnt)*1.2 ],...
%     'color',[0 0 0],'linewidth',1);
% plot([max((A - B))*1.03 max((A - B))*1.07],[max(cnt) max(cnt)],...
%     'color',[0 0 0],'linewidth',1);
% plot([min((A - B)) max((A - B))*1.03],[0 0],'-k')

%% Significance addons
eval(['[t, p] = ' params.test '(A - B,0,params.thr);']);
if  t == 1
    if p<=0.001
        stars = '***';
    elseif p <=0.01 && p>0.001
        stars = '**';
    else
        stars = '*';
    end
%     text(1.15,0.25, ['*p < ' num2str(params.thr)],...
%         'FontSize',params.fontsize,'HorizontalAlignment','left','units','normalized')
    set(gcf,'CurrentAxes',h(2))
    
    % mean difference
    text(mean(A - B),-max(cnt)*0.1, num2str(roundsd(mean(A - B),2)),...
        'FontSize',params.fontsize,'rotation',45,...
        'HorizontalAlignment','right','VerticalAlignment','middle','color',[0 0 0])
    
    plot([0 0 mean(A - B) mean(A - B)],[max(cnt)*1.3 max(cnt)*1.4 max(cnt)*1.4 max(cnt)*1.3],'-k')
    text(mean(A - B)/2,max(cnt)*1.5,stars ,'FontSize',params.fontsize,...
        'rotation',-45,'HorizontalAlignment','center','VerticalAlignment','bottom')
end

%% Labels
% Title
axes('Parent', f, 'Units', 'normalized','Position', [0, 0, 1, 1],...
    'Visible', 'off','XLim', [0, 1],'YLim', [0, 1],'NextPlot', 'add');
htitle = text(0.5,0.9,params.title,'FontSize',params.fontsize * 1.2,'fontweight','bold',...
    'HorizontalAlignment','center','units','normalized','VerticalAlignment', 'top');

% X axes labels
set(gcf,'CurrentAxes',h(1))
text(0.5,-0.15,params.names{1},'FontSize',params.fontsize,...
    'HorizontalAlignment','center','units','normalized')
text(-0.15,0.5,params.names{2},'FontSize',params.fontsize,...
    'HorizontalAlignment','center','rotation',90,'units','normalized')
set(gca,'Ytick',get(gca,'Xtick'),'yticklabel',get(gca,'xticklabel'))

%% boxplot
if params.boxplot
    lim = get(gca,'xlim');
    ticks = get(gca,'Xtick');
%     axis off
    hold on
    boxplot(B,'positions',diff(lim)*0.04+lim(1),'plotstyle','compact',...
        'medianstyle','target','labels',{''},'jitter',0)
    hold on
    boxplot(A,'positions',diff(lim)*0.04+lim(1),'plotstyle','compact',...
        'orientation','horizontal','medianstyle','target','labels',{''},'jitter',0)
    set(gca,'XTickLabel',{' '})
    set(gca,'YTickLabel',{' '})
    xlim(lim)
    ylim(lim)
    grid on
    set(gca,'Ytick',ticks,'yticklabel',[],'Xtick',ticks,'xticklabel',[],...
       'xcolor',[0.7 0.7 0.7],'ycolor',[0.7 0.7 0.7],'box','off','tickdir','out')
    for i = 1:length(ticks)
       text(lim(1)-diff(lim)*0.05,ticks(i),num2str(ticks(i)),...
           'horizontalalignment','right','verticalalignment','middle')
       text(ticks(i),lim(1)-diff(lim)*0.05,num2str(ticks(i)),...
           'horizontalalignment','right','verticalalignment','middle','rotation',45)
%        plot([ticks(i) ticks(i)],lim,'color',[0.9 0.9 0.9])
%              plot(lim,[ticks(i) ticks(i)],'color',[0.9 0.9 0.9])
%        text(lim(1),ticks(i),'-',...
%            'horizontalalignment','right','verticalalignment','middle')
%        text(ticks(i),lim(1),'-',...
%            'horizontalalignment','right','verticalalignment','middle','rotation',90)
%         line([lim(1)-diff(lim)*0.05 lim(1)],[ticks(i)-diff(lim)*0.05 ticks(i)])
    end
end 

%% Output
if nargout>0
    hOUT.axis = h;
    hOUT.title = htitle;
    hOUT.figure = f;
end
