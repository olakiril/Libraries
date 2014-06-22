function data = processScan(fn)

[data.xpos data.ypos data.zpos data.mot_t data.details] = trackMotion(fn);
[traces times] = loadTraces(fn);

ds = round((1/mean(diff(times))) / 20);
[data.traces data.time] = aodDownsample(traces,times,ds);
[c p] = princomp(traces);
data.cleanTraces = aodDownsample(traces - p(:,1:2)*c(:,1:2)',times,ds);
data.snr = diff(quantile(data.cleanTraces,[.001 .999])) ./ std(diff(data.traces));
median(data.snr)

[path fn ext] = fileparts(fn);
fn = fullfile(path,[fn '.mat']);
save(fn,'-struct','data');