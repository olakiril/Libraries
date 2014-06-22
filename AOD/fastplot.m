function fastplot(name,dsscale,scale,red)

cells = 0;
save = 0;

if nargin<2
    dsscale = 25;
    scale = 3;
end

[traces time coordinates traces2] = loadTraces(name);
cellnum = size(traces,2);

display (cellnum);

if nargin>3
    traces = traces2;
end
index = randperm(cellnum);
if cells
    traces = traces(:,index(1:cells));
end
[traces2 t2]=aodDownsample(double(traces),time,dsscale);

figure;
numpoints = 1:0.5:ceil(size(traces2,2)/2)+1;
t2 = t2(1:size(traces2,1));
plot(t2,bsxfun(@plus,traces2*scale,numpoints(1:size(traces2,2))));
title(['# cells aquired : ' num2str(cellnum)]);
set(gcf,'Color',[1 1 1]);
xlabel('Seconds')

if save
    xlim([0 120]);
end

