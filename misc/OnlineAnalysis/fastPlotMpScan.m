function fastPlotMpScan(file,lens,mag)


% read file
tpr = tpReader([file, 'p%u.h5']);
fps = getFramerate(tpr);

% check for already existing data
if ~exist([file, '.mat'],'file')
    
    % get Data
    chIm = getChannels(tpr);
    imageChannel1  = getImagingChannel(tpr,chIm(1));
    imData = getData(imageChannel1);
    greenImg = mean(imData , 3);
    
    % find cells
    pixelPitch = 11000/512/mag/lens;
    cellFinder = CellFinder( greenImg, pixelPitch, 'minRadius', 3.0, 'minDistance', 7.0, 'minContrast', 0.05 );
    
    % plot cells
    plot(cellFinder);
    
    % extract traces
    [cellTraces,neuropilTrace] = getTraces( cellFinder, imageChannel1 );
    traces = [cellTraces neuropilTrace];
    
    % save file
    dr = which([file, 'p0.h5']);
    if ~isempty(traces)
        save(dr(1:end-5),'traces')
    end
else
    load([file, '.mat'])
end

%plot
figure;
meantr = mean(traces);
nortraces = bsxfun(@minus,traces,meantr);
traces = bsxfun(@rdivide,nortraces,meantr);
numpoints = 1:0.5:ceil(size(traces,2)/2)+1;
plot((1:size(traces,1))/fps,bsxfun(@plus,traces*1,numpoints(1:size(traces,2))));
xlabel('seconds')