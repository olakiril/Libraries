function m = binMeanFromHist(p)

D = log2(length(p));
feat = isingFeature(D,1);
m = feat * p(:);