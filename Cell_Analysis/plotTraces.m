function plotTraces(cells,varargin)

params.neuropil = 0;
params.compneuropil = 0;
spacing = .4;
figure
params = getParams(params,varargin);

global dataCon
sessMan = getContext(dataCon,'Session');

% make sure we have one session
sessionId = unique(getAncestorByType(sessMan,cells,'Session'));
if(length(sessionId) > 1)
    error('This function doesn''t work for traces from different sessions');
end

stimData = getData(dataCon,sessionId,'StimulusData',struct);
expType = getMetaData(getElementById(dataCon,sessionId),'expType');

%make sure its multiDimExperiment
assert(strcmp(expType,'MultDimExperiment'));

siteId = getParent(sessMan,cells);
neuropil = filterElementByType(sessMan,'Neuropil',siteId);
cellIds = [neuropil cells];

% get data
if params.compneuropil
    opticalTrace = getData(dataCon,cellIds,'CalciumEventDetection');
    oTimes = getIndex(opticalTrace,'Times');
    oTrace = getIndex(opticalTrace,'DFoF');
    neuroTrace = getIndex(opticalTrace(1),'cDFoF');
    stDev =  - 2*std(neuroTrace(neuroTrace<0));
    neuroTrace(neuroTrace<stDev) = stDev;
    normNeTrace = (neuroTrace - min(neuroTrace))/(max(neuroTrace) - min(neuroTrace));
    baseline = prctile(oTrace',10)';
    newTraces = bsxfun(@plus,baseline,bsxfun(@times,bsxfun(@minus,oTrace,baseline),1 - normNeTrace.^2)) ;
    oTrace = [newTraces(2:end,:);oTrace];
    oTimes = [oTimes(2:end,:);oTimes ];
    % labels
    label = cell(1,size(oTrace,1));
    for i = 1:size(oTrace,1)
        y = i;
        if i > length(opticalTrace)
            y = i - length(opticalTrace);
        end
        label{i} = num2str(cellIds(y));
    end
else
    opticalTrace = getData(dataCon,cellIds,'DFoF_man','neuropil',params.neuropil);
    oTimes = getIndex(opticalTrace,'times');
    oTrace = getIndex(opticalTrace,'traceDFoF');
    % labels
    label = cell(1,size(oTrace,1));
    for i = 1:size(oTrace,1)
        label{i} = num2str(cellIds(i));
    end
end

siteTrials = getData(dataCon,siteId,'SiteTrials');
trials = getTrials( siteTrials );
stimOnsets = getEventTimes(stimData,'showSubStimulus','trials',trials,'UniformOutput',false);
stimOnsets = [stimOnsets{:}];
startTimes = stimOnsets*1000;
isd = (getConstantParam(stimData,'stimFrames'))/60; % framerate of the screen hardcoded
endTimes = startTimes + isd*1000;
orientation = getParamValues(stimData,'conditions','trials',trials,'UniformOutput',false);
ori = [orientation{:}];

uDir = unique(ori);
oColors = hsv(length(uDir))/4 + .75; %bad programming
ori = reshape(ori', 1, []);

cla
hold on
height = size(oTrace,1)*spacing;
for i = 1:length(startTimes)
    h = area([startTimes(i) endTimes(i) endTimes(i) startTimes(i)],[0 0 height height]);
    idx = find(ori(i) == uDir);
    set(h,'FaceColor',oColors(idx,:));
    set(h,'EdgeColor',oColors(idx,:));
end

for i = 1:size(oTrace,1)
    plot(oTimes(i,:),oTrace(i,:)+spacing*(i-1),'color',[0.4 0.4 0.4]);
end

colormap(hsv(length(uDir))/4 + .75)
colorbar('location','southoutside');
set(gca,'CLim',[0 16])

oldAxis = gca;
cAxis_pos = get(gca,'position');
nAxis = subplot('position',[cAxis_pos(1)+cAxis_pos(3),cAxis_pos(2), .0001, cAxis_pos(4)] );
set(nAxis,'yaxisLocation', 'right');
set(nAxis,'yGrid','off');
set(nAxis,'xGrid','off');
set(nAxis, 'ylim', get(oldAxis, 'ylim'));
set(nAxis, 'YTick', spacing*(0:size(oTrace,1)-1));
set(nAxis, 'XTick', spacing*(0:size(oTrace,1)-1));
set(oldAxis,'box','off');
linkprop([nAxis, oldAxis], {'yLim'});
set(nAxis,'yTickLabel',label);
axes(oldAxis);
linkaxes([oldAxis,nAxis],'y');