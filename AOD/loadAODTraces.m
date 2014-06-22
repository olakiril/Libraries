function [traces, t, coordinates, traces2] = loadAODTraces(fn,fps)

mode = aodReader(fn,'Functional');
assert(~isempty(mode), 'Cannot find mode information, invalid AOD scan file');

if nargout>2
    coordinates = mode.coordinates;
end

traces = mode(:,:,1);
dt = 1/mode.Fs;
t = (1:size(traces,1)) * dt ;

if nargout >3
    traces2 = mode(:,:,2);
end

if nargin<2
   fps = 40;
end

if nargin ~= 0 && fps~=0
    
    d = max(1,round(1/mean(diff(t))/fps));
    k = ones(d,1)/d;
    traces = conv2(traces,k,'valid');
    traces = traces(1:d:end,:);
    
    if nargout >= 4
        traces2 = conv2(traces2,k,'valid');
        traces2 = traces2(1:d:end,:);
    end
    
    t = t(1:d:end);
end