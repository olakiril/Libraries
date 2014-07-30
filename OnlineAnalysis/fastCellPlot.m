function fastCellPlot(name,scale,mfactor)

if nargin<2
    scale = 20;
    
end
if nargin<3
    mfactor = 1;
end

% check for file
if ~exist([name, '_site.mat'],'file')
    if ~exist([name, 'p0.h5'],'file')
        error('File does not exist');
    else
        fastSiteFile(name);
    end
end

% load file
load ([name, '_site.mat'])

% get Data
traces = siteFile.traces;
time = (1:size(traces,1))/siteFile.Fps;

[traces time] = traceDownsample(traces,time,scale);
figure
plot(time,bsxfun(@plus,traces*mfactor,1:size(traces,2)));