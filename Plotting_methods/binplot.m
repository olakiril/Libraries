function [binYm,binYe,bins] = binplot(x,y,bins)

if nargin<3
    bins = min(x):(max(x)-min(x))/5:max(x);
end
bins = sort(bins);
binYm = nan(length(bins),1);
binYe = nan(length(bins),1);

for ibin = 1:length(bins)
    indx = x <= bins(ibin);
    binYm(ibin) = mean(y(indx));
    binYe(ibin) = std(y(indx))/sqrt(sum(indx));
    y(indx) = [];
    x(indx) = [];
end

if ~nargout
    errorbar(binYm,binYe)
    set(gca,'xtick',1:length(bins),'xticklabel',roundall(bins,0.01))
    xticklabel_rotate([],90,[])
end