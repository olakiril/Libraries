function animateCells(fn)

params.fs = 30;

[traces time coordinates] = loadAODTraces(fn);
ds = round(1 / mean(diff(time)) / params.fs);

[c p] = princomp(traces);
traces2 = aodDownsample(traces - p(:,1)*c(:,1)',time,ds);

range = quantile(traces2,[.001 .995]);
traces3 = bsxfun(@rdivide,bsxfun(@minus,traces2,range(1,:)),diff(range));
traces3(traces3(:) < 0) = 0;
traces3(traces3(:) > 1) = 1;

for i = 1:size(traces2,1)
    scatter3(coordinates(:,1),coordinates(:,2),coordinates(:,3),105,[traces2(i,:)' .1*ones(size(traces,2),2)],'.');
    view([i 30]);
    set(gca,'Box','off')
    drawnow
end