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
params.markersize = 2;
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
params.reduce = 0.7;
params.ticks = [];

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

% non variable size params
left_margin = 0.15;      % normalized left margin for scatter plot
bottom_margin = 0.15;    % normalized bottom margin for scatter plot
expansion = 0.5;         % normalized width and height of scatter plot

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

% scatter plot
h = subplot(223);
plot(A,B,params.markertype,'markersize',params.markersize,...
    'MarkerEdgeColor',params.MarkerEdgeColor,'MarkerFaceColor',params.MarkerFaceColor);

mn = min([A; B]); mx = max([A; B]);
set(gca,'Xlim',[mn*params.reduce mx/params.reduce],'YLim',[mn*params.reduce mx/params.reduce]);
if params.ticks
    set(gca,'xtick',params.ticks,...
        'ytick',params.ticks);
end 
pos = get(h,'Position');
set(h,'Position',[pos(1),pos(2),...
    (pos(3) + pos(4))/2, (pos(3) + pos(4))/2],'box','off',...
    'FontSize',params.fontsize); % equalize axis
hold on
plot([mn*params.reduce mx/((1+params.reduce)/2)],[mn*params.reduce mx/((1+params.reduce)/2)],...
    params.diagtype,'Color',params.midlinecolor,'LineWidth',params.midlinewidth);

% histogram
difrange = (max((A - B)) - min(A - B))*params.heightgain/(mx - mn);
bin = round(difrange*params.maxbin/(2*params.heightgain));
h(2) = subplot(222);
hist(A - B,bin);
cnt = hist(A - B,bin);
lim = get(h(2),'YLim');
set(gca,'XLim',[-max(abs(A - B)) max(abs(A - B))],...
    'YLim',[lim(1) lim(2)*(difrange)],'YColor',[1 1 1]);% equalize axis & reduce y axis
camorbit(45,0,'data',[0 0 1]);

% get proper position
set(h(1),'position',[left_margin bottom_margin expansion expansion]/((1+params.reduce)/2))
pos = get(h(1),'position');
w2 = 4 * max(abs(A - B)) * pos(3) / ((mx - mn) * 2);
set(h(2),'Position',[pos(1) + pos(3)*(1+params.reduce)/2 - w2/4,...
    pos(2) + pos(4)*(1+params.reduce)/2 - w2/4, w2*params.reduce, w2*params.reduce],...
    'YTick',round(max(cnt)/10)*10,'YTickLabel',[],'box','off','YAxisLocation','right',...
    'xtick',[],'tickdir','out','xcolor',[1 1 1],'tickdir','in')
h(3) = findobj(gca,'Type','patch');
set(h(3),'FaceColor',params.histcolor,'EdgeColor',params.histedgecolor)
hold on;
plot([0 0],get(h(2),'YLim'),params.diagtype,'Color',params.midlinecolor,'LineWidth',params.midlinewidth) % midline
plot([mean(A - B) mean(A - B)],[0 max(cnt) * 1.2],params.meantype,'LineWidth',params.midlinewidth,...
    'color',params.difcolor) %diff
text(max((A - B))*1.05,max(cnt), num2str(max(cnt)),...
    'FontSize',params.fontsize,'rotation',45,...
    'HorizontalAlignment','center','VerticalAlignment','top')

% mask the extra axis
plot([0 0],[max(cnt)*1.2 lim(2)*difrange],'Color',[1 1 1],'linewidth',4);
plot([max((A - B))*1.03 max((A - B))*1.03],[0 max(cnt)*1.2 ],...
    'color',[0 0 0],'linewidth',1);
plot([max((A - B))*1.03 max((A - B))*1.07],[max(cnt) max(cnt)],...
    'color',[0 0 0],'linewidth',1);
plot([min((A - B)) max((A - B))*1.03],[0 0],'-k')

% X axes labels
set(gcf,'CurrentAxes',h(1))
text(0.5,-0.15,params.names{1},'FontSize',params.fontsize,...
    'HorizontalAlignment','center','units','normalized')
text(-0.15,0.5,params.names{2},'FontSize',params.fontsize,...
    'HorizontalAlignment','center','rotation',90,'units','normalized')
set(gca,'Ytick',get(gca,'Xtick'),'yticklabel',get(gca,'xticklabel'))

% Significance addons
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

% Title
axes('Parent', f, 'Units', 'normalized','Position', [0, 0, 1, 1],...
    'Visible', 'off','XLim', [0, 1],'YLim', [0, 1],'NextPlot', 'add');
htitle = text(0.5,0.9,params.title,'FontSize',params.fontsize * 1.2,'fontweight','bold',...
    'HorizontalAlignment','center','units','normalized','VerticalAlignment', 'top');
set(gcf,'CurrentAxes',h(1))

if nargout>0
    hOUT.axis = h;
    hOUT.title = htitle;
    hOUT.figure = f;
end
