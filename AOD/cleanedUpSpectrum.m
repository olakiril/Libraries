function [rCxy cCxy f] = cleanedUpSpectrum(traces,t)

fmax = 1 / mean(diff(t));
perms = combnk(1:size(traces,2),2);

traces = bsxfun(@minus,traces,mean(traces));
[c p] = princomp(traces);

cleanTraces = traces - p(:,1)*c(:,1)';

for i = size(perms,1):-1:1
    [rCxy(:,i) f] = mscohere(traces(:,perms(i,1)),traces(:,perms(i,2)),3000,[],[],fmax);
    [cCxy(:,i) f] = mscohere(cleanTraces(:,perms(i,1)),cleanTraces(:,perms(i,2)),3000,[],[],fmax);
end