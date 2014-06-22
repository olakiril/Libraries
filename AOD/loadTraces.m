function [traces, t, coordinates, traces2] = loadTraces(fn,fps)

mode = loadHWS(fn,'config','mode');
assert(~isempty(mode), 'Cannot find mode information, invalid AOD scan file');
assert(mode(1) == 0, 'Points not found in volume scans');

coordinates = loadPoints(fn);
np = size(coordinates,1)-double(mode(4));
coordinates = coordinates(1:np,:);

[dat, dt] = loadHWS(fn,'ImData','ImCh1');
traces = reshape(double(dat(1:np*floor(numel(dat)/np))),np,[])';
t = (1:size(traces,1)) * dt * np;

if nargout >= 4
    dat = loadHWS(fn,'ImData','ImCh2');
    traces2 = reshape(double(dat(1:np*floor(numel(dat)/np))),np,[])';
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