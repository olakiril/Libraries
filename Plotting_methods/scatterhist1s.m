function [hOUT mOUT pOUT] = scatterhist1s(A,B,varargin)

% function scatterhist1(A,B,varargin)
%
% scatterhist1 gives a scatter plot of the two vectors and a histogram of
% their difference in which a significance student t-test is performed.
%
% MF 2011-09-01

% variable params
params.midlinecolor = [0 0 0];
params.markersize = 2;
params.markertype = 'O';
params.markercolor = [0.2 0.2 0.2];
params.histcolor = [0.5 0.5 0.5];
params.difcolor = [1 0 0];
params.thr = 0.001;
params.names = [{''},{''}];
params.bin = 20;
params.title = '';
params.fontsize = 12;
params.diagtype = '-.';
params.meantype = '--';
params.constrict = [99.99 99.99; 1 1];
params.offset = 0.001;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

% non variable size params
hist_compression = 0.25; % height/width ratio for histogram
left_margin = 0.15;      % normalized left margin for scatter plot
bottom_margin = 0.15;    % normalized bottom margin for scatter plot
expansion = 0.5;         % normalized width and height of scatter plot

roundAll = @(x) round(x*10^abs(floor(log10(x))))/10^abs(floor(log10(x)));

% make sure vectors have the proper size and type
A = double(reshape(A,numel(A),1));
B = double(reshape(B,numel(B),1));

% remove outliers
if params.constrict
    i = A<prctile(A,params.constrict(1,2)) & A>prctile(A,params.constrict(2,2))...
        & B<prctile(B,params.constrict(1,1)) & B>prctile(B,params.constrict(2,1));
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
f = figure;
set(f,'Name',params.title,'position',[300,300,500,500])
set(gcf,'Color',[1 1 1])

% scatter plot
h = subplot(223);
plot(A,B,params.markertype,'markersize',params.markersize,...
    'MarkerEdgeColor',params.markercolor,'MarkerFaceColor',params.markercolor);
mn = min([A; B]); mx = max([A; B]);
set(gca,'Xlim',[mn mx],'YLim',[mn mx]);
pos = get(h,'Position');
set(h,'Position',[pos(1),pos(2),...
    (pos(3) + pos(4))/2, (pos(3) + pos(4))/2],'box','off',...
    'FontSize',params.fontsize); % equalize axis
hold on
plot([mn mx],[mn mx],params.diagtype,'Color',params.midlinecolor,'LineWidth',2);

% histogram
h(2) = subplot(222);
edges = -mx:(2*mx)/(params.bin - 1):mx;
cnt = histc(A - B,edges);
nonz = params.bin-sum(cnt == 0); % check that the number of bins are close to what is asked.
bins = round(params.bin^2/nonz); 
edges = -mx:(2*mx)/(bins - 1):mx;
cnt = histc(A - B,edges);
bar(edges,cnt,'histc');
lim = get(h(2),'YLim');
set(gca,'XLim',[-max(abs(A - B)) max(abs(A - B))],'YLim',[lim(1) lim(2)/hist_compression],...
    'YColor',[1 1 1]);% equalize axis & reduce y axis
camorbit(45,0,'data',[0 0 1]);

% get proper position
set(h(1),'position',[left_margin bottom_margin expansion expansion])
pos = get(h(1),'position');
w2 = 4 * max(abs(A - B))* pos(3) / ((mx - mn) * 2);
set(h(2),'Position',[pos(1) + pos(3) - w2/4, pos(2) + pos(4) - w2/4, w2, w2],...
    'YTick',round(max(cnt)/10)*10,'YTickLabel',[],'box','off','YAxisLocation','right',...
    'xtick',[],'tickdir','out','xcolor',[0 0 0],'tickdir','in')
h(3) = findobj(gca,'Type','patch');
set(h(3),'FaceColor',params.histcolor,'EdgeColor',[0 0 0])
hold on;
plot([0 0],get(h(2),'YLim'),params.diagtype,'Color',params.midlinecolor,'LineWidth',2) % midline
plot([mean(A - B) mean(A - B)],[0 max(cnt) * 1.2],params.meantype,'LineWidth',2,...
    'color',params.difcolor) %diff
offset = params.offset*mx;
text(max((A - B))+offset*1.1,round(max(cnt)/10)*10, num2str(round(max(cnt)/10)*10),...
    'FontSize',params.fontsize,'rotation',45,...
    'HorizontalAlignment','center','VerticalAlignment','top')

% mask the extra axis
plot([0 0],[max(cnt)*1.2 lim(2)/hist_compression],'Color',[1 1 1],'linewidth',4);
plot([max((A - B))+offset max((A - B))+offset],[0 max(cnt)*1.2 ],...
    'color',[0 0 0],'linewidth',1);
plot([max((A - B))+offset max((A - B))+offset*1.1],[round(max(cnt)/10)*10 round(max(cnt)/10)*10],...
    'color',[0 0 0],'linewidth',1);
% plot([min((A - B))-offset max((A - B))+offset],[0 0],'-k')

% X axes labels
set(gcf,'CurrentAxes',h(1))
text(0.5,-0.15,params.names{1},'FontSize',params.fontsize,...
    'HorizontalAlignment','center','units','normalized')
text(-0.15,0.5,params.names{2},'FontSize',params.fontsize,...
    'HorizontalAlignment','center','rotation',90,'units','normalized')

% Significance addons
if ttest(A - B,0,params.thr) == 1
    text(1.25,0.25, ['*p < ' num2str(params.thr)],...
        'FontSize',params.fontsize,'HorizontalAlignment','left','units','normalized')
    set(gcf,'CurrentAxes',h(2))
    
    % mean difference
    text(mean(A - B),-max(cnt)*0.1, num2str(roundAll(mean(A - B))),...
        'FontSize',params.fontsize,'rotation',45,...
        'HorizontalAlignment','right','VerticalAlignment','middle')
    
    plot([0 0 mean(A - B) mean(A - B)],[max(cnt)*1.3 max(cnt)*1.4 max(cnt)*1.4 max(cnt)*1.3],'-k')
    text(mean(A - B)/2,max(cnt)*1.5, '*','FontSize',params.fontsize,...
        'rotation',-45,'HorizontalAlignment','center','VerticalAlignment','middle')
end

% Title
set(gcf,'CurrentAxes',h(2))
text(0,0.55,params.title,'FontSize',params.fontsize * 1.2,...
    'HorizontalAlignment','center','units','normalized')

if nargout>0
    hOUT = h;
end
