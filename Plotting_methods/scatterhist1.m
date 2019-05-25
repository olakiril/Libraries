function hOUT = scatterhist1(A,B,varargin)

% function scatterhist1(A,B,varargin)
%
% scatterhist1 gives a scatter plot of the two vectors and a histogram of
% their difference in which a significance student t-test is performed.
%
% MF 2011-09-01

%% variable params
params.midlinecolor = [0.5 0.5 0.5];
params.midlinewidth = 1;
params.markersize = 20;
params.markertype = 'O';
params.MarkerEdgeColor = 'none';
params.color = [0.2 0.2 0.2];
params.names = [{''},{''}];
params.maxbin = 40;
params.title = '';
params.fontsize = 10;
params.diagtype = '--';
params.meantype = '-';
params.constrict = []; % take a % of the data.
params.heightgain = 2;
params.offset = 0;
params.figure = [];
params.reduce = 1;
params.ticks = [];
params.boxplot = false;
params.MarkerFaceAlpha = 0.5;
params.margin= 0.15;

% hist params
params.histcolor = [0.5 0.5 0.5];
params.histedgecolor = 'none';
params.difcolor = [1 0 0];
params.thr = 0.05;
params.test = 'ttest';

% assign groups if 3 input is not a parameter
if nargin>2 && ~(isstring(varargin{1}) || ischar(varargin{1}))
    Groups = varargin{1};
    varargin = varargin(2:end);
else
    Groups = ones(size(A));
end
un_group = unique(Groups);

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

if params.boxplot; params.reduce = params.reduce+0.2;end

% check colors to match group number
if isempty(params.color)  || size(params.color,1)<length(un_group)
    params.color = cbrewer('qual','Pastel1',max([length(un_group),3]));
end
if isempty(params.histcolor)  || size(params.histcolor,1)<length(un_group)
    params.histcolor = params.color;
end
if isempty(params.difcolor)  || size(params.difcolor,1)<length(un_group)
    params.difcolor = params.color*0.8;
end

% non variable size params
left_margin = params.margin;      % normalized left margin for scatter plot
bottom_margin = params.margin;    % normalized bottom margin for scatter plot
expansion = 0.5*(params.reduce^(1/3));         % normalized width and height of scatter plot

% make sure vectors have the proper size and type
A = double(reshape(A,numel(A),1));
B = double(reshape(B,numel(B),1));

% remove outliers
if params.constrict
    uth = prctile([A(:);B(:)],params.constrict);
    lth = prctile([A(:);B(:)],100 - params.constrict);
    i = A < uth & A > lth & B < uth & B > lth;
    A = A(i);
    B = B(i);
end

% create figure
if isempty(params.figure)
    f = figure;
%     set(f,'Name',params.title,'position',[200,200,500,500])
    set(f,'position',[200,200,500,500])

else
    f = params.figure;
end
set(gcf,'Color',[1 1 1])

%% scatter plot
h = subplot(223);
hold on
for igroup = 1:length(un_group)
    group_idx = Groups==un_group(igroup);
    scatter(A(group_idx),B(group_idx),'filled',params.markertype,'SizeData',params.markersize,...
        'MarkerEdgeColor','none','MarkerFaceColor',params.color(igroup,:),'MarkerFaceAlpha',params.MarkerFaceAlpha);
end

mn = min([A; B]) - params.offset; mx = max([A; B])*params.reduce;
set(gca,'Xlim',[mn mx],'YLim',[mn mx]);
if params.ticks
    set(gca,'xtick',params.ticks,...
        'ytick',params.ticks);
end 
pos = get(h,'Position');
set(h,'Position',[pos(1),pos(2),...
    (pos(3) + pos(4))/2, (pos(3) + pos(4))/2],'box','off',...
    'FontSize',params.fontsize); % equalize axis
hold on
plot([mn mx],[mn mx],...
    params.diagtype,'Color',params.midlinecolor,'LineWidth',params.midlinewidth);
axis square
grid on

%% histogram
h(2) = subplot(222);
hold on
difrange = (max((A - B)) - min(A - B))*params.heightgain/(mx - mn);
bin = round(difrange*params.maxbin/(2*params.heightgain));
cnt = [];
for igroup = 1:length(un_group)
    group_idx = Groups==un_group(igroup);
    hh = histogram(A(group_idx) - B(group_idx),bin);
    set(hh,'FaceColor',params.histcolor(igroup,:),'EdgeColor',params.histedgecolor)
    cnt{igroup} = hh.Values;
end
cnt = [cnt{:}];
plot([0 0],[0 1]*max(cnt)*1.2,params.diagtype,'Color',params.midlinecolor,'LineWidth',params.midlinewidth)
lim = get(h(2),'YLim');
set(gca,'XLim',[-max(abs(A - B)) max(abs(A - B))],...
    'YLim',[lim(1) lim(2)*(difrange)],'YColor',[1 1 1]);% equalize axis & reduce y axis
camorbit(45,0,'data',[0 0 1]);

%% get proper position

set(h(1),'position',[left_margin bottom_margin expansion expansion])
pos = get(h(1),'position');
w2 = 4 * max(abs(A - B)) * pos(3) / ((mx - mn) * 2);
set(h(2),'Position',[pos(1) + pos(3) - w2/4*params.reduce^sqrt(2),...
    pos(2) + pos(4) - w2/4*params.reduce^sqrt(2), w2, w2],...
    'YTick',round(max(cnt)/10)*10,'YTickLabel',[],'box','off','YAxisLocation','right',...
    'xtick',[],'ytick',[],'tickdir','out','xcolor',[1 1 1],'tickdir','in')

%% plot extra stuff on histogram
hold on;
for igroup = 1:length(un_group)
    group_idx = Groups==un_group(igroup);
    plot([1 1]*nanmean(A(group_idx) - B(group_idx)),[0 max(cnt) * 1.2],params.meantype,...
        'LineWidth',params.midlinewidth,'color',params.difcolor(igroup,:)) % mean diff line
end
axis off
count = ceil(max(cnt)/2);
offset = max(cnt)/4;
text(max(A - B),offset+count/2, num2str(count),...
    'FontSize',params.fontsize,'rotation',45,...
    'HorizontalAlignment','center','VerticalAlignment','top')
barpos = max(A - B)-0.01*(max(A - B)-min(A - B));
plot([barpos barpos],[offset offset+count],'color',[0 0 0])

%% Significance addons
for igroup = 1:length(un_group)
    group_idx = Groups==un_group(igroup);
    mDif = nanmean(A(group_idx) - B(group_idx));
    if strcmp(params.test,'signrank')
        eval(['[p, t] = ' params.test '(A(group_idx) - B(group_idx),[],''alpha'',params.thr);']);
        
    else
        eval(['[t, p] = ' params.test '(A(group_idx) - B(group_idx),0,params.thr);']);
    end
    if  t == 1
        if p<=0.001; stars = '***'; elseif p <=0.01 && p>0.001;stars = '**'; else; stars = '*'; end
        set(gcf,'CurrentAxes',h(2))

        % mean difference
        text(mDif,-max(cnt)*0.1, num2str(roundsd(mDif,2)),...
            'FontSize',params.fontsize,'rotation',45,...
            'HorizontalAlignment','right','VerticalAlignment','middle','color',params.difcolor(igroup,:))

        plot([0 0 mDif mDif],[max(cnt)*1.3 max(cnt)*1.4 max(cnt)*1.4 max(cnt)*1.3],'-k')
        text(mDif/2,max(cnt)*1.5,stars ,'FontSize',params.fontsize,...
            'rotation',-45,'HorizontalAlignment','center','VerticalAlignment','bottom')
    end
end

%% Labels
% Title
axes('Parent', f, 'Units', 'normalized','Position', [0, 0, 1, 1],...
    'Visible', 'off','XLim', [0, 1],'YLim', [0, 1],'NextPlot', 'add');
htitle = text(0.5,0.9,params.title,'FontSize',params.fontsize * 1.5,'fontweight','bold',...
    'HorizontalAlignment','center','units','normalized','VerticalAlignment', 'top');

% X axes labels
set(gcf,'CurrentAxes',h(1))
xlabel(params.names{1},'FontSize',params.fontsize*1.2)
ylabel(params.names{2},'FontSize',params.fontsize*1.2)

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
