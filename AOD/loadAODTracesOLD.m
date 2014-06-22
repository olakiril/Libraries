function [traces time coordinates] = loadAODTraces(fn)
% Load AOD traces
% [traces time coordinates] = loadAODTraces(fn)
% 
% JC 2010-04-09

% PS: Manolis, don't make this function ugly!

dat = loadAODFile(fn);

[foo idx] = sort(cellfun(@length,dat));
dat = dat(idx);

assert(dat{1}(1) == 0, 'Not a traces file');

coordinates = bsxfun(@rdivide,reshape(double(dat{2}),3,[])',[1460000 1460000 700]);
traces = double(reshape(dat{3},size(coordinates,1),[])');
time = (1:size(traces,1)) / (50000/size(traces,2));


