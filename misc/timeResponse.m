function timeResponse(days,varargin)

% function timeResponse(days,varargin)
%
% plots the raw response across time for all the cells
%
% MF 2009-05-05

params.Thr = 0.05;
params.contrast = 0;
params.respOnset = 5;
params.respOffset = 7;
params.orientation = 0;
params.variance = 0;
params.neuropil = 0;

params = getParams(params,varargin);

global dataCon;
sessMan = getContext(dataCon,'Session');

% get the cells
Sites = cell(1,size(days,1));
for i = 1:size(days,1)
    Sites{i} = filterElementbyMeta(sessMan,'Site','mouseId',days(i,:));
end
sites = cell2mat(Sites);
cells = filterElementByType(sessMan,'Cell',sites);
[meanBinResp,standardErr] = cellResponse(cells,params);
plotResponse(meanBinResp,standardErr);

if params.neuropil
    neuropil = filterElementByType(sessMan,'Neuropil',sites);
    neuropil = neuropil(findMetaDataVec(sessMan,sites,'segment')==1);
    [meanBinResp,standardErr] = cellResponse(neuropil,params);
    hold on
    errorbar(meanBinResp,standardErr,'r');    
end


end
    
function [meanBinResp,standardErr] = cellResponse(cells,varargin)
params = [];
params = getParams(params,varargin);
global dataCon;

% get the data for the cells
revCorr = getData(dataCon,cells,'ReverseCorrelation');
revCorrStats = getData(dataCon,cells,'RevCorrStats');

% get the tunned cells only
pOti = getIndex(revCorrStats,'Poti');
tunIndx = pOti <= params.Thr;
revCorr = revCorr(tunIndx);
revCorrStats = revCorrStats(tunIndx);

% find direction prefference
prefDir = getVonMises(revCorrStats,4);
orientations = 0:45:315;

binResp = cell(1,length(revCorr));

for indxCell = 1:length(revCorr);
    reverseCorrelation = revCorr(indxCell);

    % get the data we need
    binArea = getIndex(reverseCorrelation,'binArea');
    conditions = getIndex(reverseCorrelation,'conditions');
    conditionsIndex = getIndex(reverseCorrelation,'conditionsIndex');

    % choose parameters
    if params.contrast
        indxContrast = [conditions.contrast] == params.contrast;
    else
        indxContrast = [conditions.contrast] >.1;
    end

    conditions = conditions(indxContrast);
    useTrials = find((indxContrast));
    indxConditions = ismember(conditionsIndex,useTrials);
    conditionsIndex = conditionsIndex(indxConditions);
    binArea = binArea(indxConditions,:);

    oriIndx = find(prefDir(indxCell)*180/pi>orientations,1,'last');

    % orientation prefference
    if params.orientation
        if oriIndx==8
            indxOrientation = [conditions.orientation]==orientations(oriIndx) | [conditions.orientation]==0;
        else
            indxOrientation = [conditions.orientation]==orientations(oriIndx) | [conditions.orientation]==orientations(oriIndx+1);
        end

        useTrials = find((indxOrientation));
        indxConditions = ismember(conditionsIndex,useTrials);
        binArea = binArea(indxConditions,:);
    end

    % mean across trial response time
    binAreaMean = mean(binArea(:,params.respOnset:params.respOffset),2);
    while round(length(binAreaMean)/length(conditions))~=length(binAreaMean)/length(conditions)
        binAreaMean(1) = [];
    end

    binResp{indxCell} = mean(reshape(binAreaMean',length(conditions),[]),1);
end

% remove cells that don't have the same number of trials as the majority of
% the cells
lengthCell = cellfun('length',binResp);
maxCell  = median(lengthCell);
binResp = binResp(lengthCell==maxCell);
binResp = cell2mat(binResp');


variance = var(binResp,1);
standardErr = sqrt(variance./size(binResp,1));
meanBinResp = mean(binResp,1);

if params.variance
    standardErr = variance;
end

end

function plotResponse(meanBinResp,standardErr)

errorbar(meanBinResp,standardErr)
set(gcf,'Color',[1 1 1])
set(gca,'Box','off')
ylabel('Response Amplitude')
xlabel('trials')
title('Time Response');
end







