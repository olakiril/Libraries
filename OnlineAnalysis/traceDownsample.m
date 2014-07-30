function [traces t] = traceDownsample(traces,t,ds)

f = factor(ds);

for i = 1:size(traces,2)
    temp = traces(:,i);
    for j = 1:length(f)
        temp = decimate(temp,f(j));
    end
    traces2(:,i) = temp; %#ok<AGROW>
end
traces = traces2;
t = t(1:ds:end);

m = mean(traces,1);
traces = bsxfun(@rdivide,bsxfun(@minus,traces,m),m);