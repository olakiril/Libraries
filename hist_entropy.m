function H = hist_entropy(x,bins)
if nargin<2
  [counts, binedges]= histcounts(x);  
else
  [counts, binedges]= histcounts(x,bins);  
end
binCenters = binedges(1:end-1) + diff(binedges)/2;
binWidth = diff(binCenters);
binWidth = [binWidth(end),binWidth]; % Replicate last bin width for first, which is indeterminate.
nz = counts>0; % Index to non-zero bins
frequency = counts(nz)/sum(counts(nz));
H = -sum(frequency.*log(frequency./binWidth(nz)));