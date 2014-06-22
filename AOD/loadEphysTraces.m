function [traces time ephys ephysTime coordinates] = loadEphysTraces(fn)
% Load ephys and traces
% [traces time ephys ephysTime coordinates] = loadEphysTraces(fn)
% 
% JC 2010-04-09

% PS: Manolis, don't make this function ugly!

dat = loadAODFile(fn);

[foo idx] = sort(cellfun(@length,dat));
dat = dat(idx);

coordinates = bsxfun(@rdivide,reshape(double(dat{2}),3,[])',[1460000 1460000 700]);

% extract ephys points (every other one)
dat{3} = reshape(dat{3},2,[])';
ephys = dat{3}(:,1);
ephysTime = (1:length(ephys))/50000;

dat{3} = dat{3}(:,2);
traces = reshape(dat{3},size(coordinates,1),[])';
time = (1:size(traces,1)) / (50000/size(traces,2));


