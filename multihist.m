function indxOUT = multihist(data,varargin)

% function multihist(data,varargin)
%
% automatically overplots the histograms of the data as a simple plot
%
% MF 2011-09-01

if ~iscell(data);data = {data};end

params.linestyle = '-';
params.linewidth = 2;
params.colors = parula(length(data));
params.bin = round(mean(cellfun(@length,data))/50);
params.normalize = 1;
params.eq = 1;
params.cumsum = 0;
params.indx = [];
params.stairs = 1;

params = getParams(params,varargin);

if params.bin<10;params.bin = 10;end

% linearize data
data = cellfun(@(x) reshape(x,1,[]),data,'uniformoutput',0);

if params.eq && isempty(params.indx)
    mx = max([data{:}]);
    mn = min([data{:}]);
    indx = mn:(mx-mn)/(params.bin - 1):mx;
elseif ~isempty(params.indx)
    indx = params.indx;   
    params.eq = 1;
end

for i = 1:length(data)
    if params.eq
        n1 = histc(data{i},indx);
    else
        [n1, indx] = hist(data{i},params.bin);
    end
    if params.normalize
        n1 = n1/sum(n1);
    end
    if params.cumsum
        n1 = cumsum(n1);
    end
    
    if params.stairs
        stairs(indx,n1,params.linestyle,'Color',params.colors(i,:),'linewidth',params.linewidth);
    else
        plot(indx, n1,params.linestyle,'Color',params.colors(i,:),'linewidth',params.linewidth);
    end
    set(gca,'box','off')
    hold on;
end


if nargout>0
    indxOUT = indx;
end