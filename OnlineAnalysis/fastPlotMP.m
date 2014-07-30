function fastPlotMP(name,scale)

if nargin<2
    scale = 1;
end
figure;
load (name)
tr = siteFile.traces;
meantr = mean(tr);
nortraces = bsxfun(@minus,tr,meantr);
traces = bsxfun(@rdivide,nortraces,meantr);
numpoints = 1:0.5:ceil(size(traces,2)/2)+1;
plot(bsxfun(@plus,traces*scale,numpoints(1:size(traces,2))));