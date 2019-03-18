function fancyPolar(data,varargin) 

params.bins = 10;
params.colormap = [];
params.normalize = true;
params.tight = 0;
params.figure = [];
params.alpha = 0.7;
params.lim = [];
params.fig_color = [1 1 1];

params = getParams(params,varargin);


% generate colormaps for spirals
if isempty(params.colormap)
    params.colormap= flipud(cbrewer('div','RdBu',params.bins));
end

% get data information
sz = size(data);
n = numel(data);
sub_idx = ((1:sz(1)) - 1)'*sz(2)+ (1:sz(2));
if isempty(params.lim)
    params.lim(1) = min(reshape(cellfun(@min,data),[],1));
    params.lim(2) = max(reshape(cellfun(@max,data),[],1));
end

% set figure
if isempty(params.figure);  params.figure = figure;end
set( params.figure,'Color',params.fig_color) %change figure background
pos = get( params.figure,'position');
set( params.figure,'position',[pos(1:3) pos(3)*sz(1)/sz(2)])

% loop over data
for k =1:n
    subplot_tight(sz(1),sz(2),sub_idx(k),params.tight)
    sub_data = histcounts(data{k},linspace(params.lim(1),params.lim(2),params.bins+1));
    sub_data = normalize(sub_data);
    
    if ~params.normalize
        sub_data = sub_data/sum(sub_data);
    end
    
    % loop over hist bins
    for ll=1:params.bins
        
        values = zeros(params.bins,1);
        values(params.bins - ll + 1) = sub_data(ll);
        hax = polarhistogram('BinEdges',linspace(0,2*pi,params.bins+1),'BinCounts',values);
        
        hax.EdgeColor = 'none';
        hax.FaceColor = params.colormap(ll,:);
        hax.FaceAlpha = params.alpha;
        
        hold on
        axis off
    end
    
    a = gca;
    a.RLim = [0 1];
    hold off
end