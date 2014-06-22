function out = getObjectData(days,varargin)

% function getObjectData(day,varargin)
%
% Gets data
%
% MF 2009-05-01

params.input = 'day';
params.contrast = [];
params.spatialFreq = [];
params.output = 0;
params.experiment = 0;
params.split = 0;
params.neuropil = 0;
params.pca = 0;
params.CorrelationType = [];


params = getParams(params,varargin);
global dataCon;

if isobject(days) % check if everything is already calculated
    out = days;
    return
elseif iscell(days)
    if isobject(days{1}) % check if everything is already calculated
        out = days;
        return
    end
end

sessMan = getContext(dataCon,'Session');

if strcmp(params.input,'day')
    % get all sites
    Sites = cell(1, size(days,1));
    for l = 1: size(days,1)
        day = days(l,:);
        fun = @(e) strcmp(getMetaData(e,'mouseId'),day);
        mouseId = filterElementByFun(sessMan,'Subject',fun);
        Sites{l} = filterElementByType(sessMan,'Site',mouseId);
        if params.experiment
            Sites{l} = filterSites(Sites{l},'experiment',params.experiment);
        end
    end
    sites = cell2mat(Sites);
   
    if strcmp(params.output,'sites')
        out = Sites;
        return
    end
    cells = filterElementByType(sessMan,'Cell',sites);
    
elseif strcmp(params.input,'site')
    % if sites is given get all the cells
    cells = filterElementByType(sessMan,'Cell',days);
else
    % if only one cell is given
    cells = days;
end

% find correlation type if not specified
if isempty(params.CorrelationType)
    params.CorrelationType = findCorrelationType(getParent(sessMan,cells(1)));
end

% get data
if length(params.contrast)==1 && length(params.spatialFreq)==1
    out = getData(dataCon,cells,params.CorrelationType,...
        'spatialFreq',params.spatialFreq,'contrast',params.contrast);
    % get data for different contrasts seperatly
elseif length(params.contrast)>1
    params.contrast = sort(params.contrast,'descend');
    out = cell(1,length(params.contrast));
    for i = 1:length(params.contrast)
        out{i} = getData(dataCon,cells,params.CorrelationType,...
            'spatialFreq',params.spatialFreq,'contrast',params.contrast(i));
    end
    % get data for different spatial Frequencies seperatly
elseif length(params.spatialFreq)>1
    params.spatialFreq = sort(params.spatialFreq,'descend');
    out = cell(1,length(params.spatialFreq));
    for i = 1:length(params.spatialFreq)
        out{i} = getData(dataCon,cells,params.CorrelationType,...
            'spatialFreq',params.spatialFreq(i),'contrast',params.contrast);
    end
elseif params.split
    out = getData(dataCon,cells,params.CorrelationType,'split',params.split);
elseif params.neuropil
    out = getData(dataCon,cells,params.CorrelationType,'neuropil',params.neuropil);
elseif params.pca
    out = getData(dataCon,cells,params.CorrelationType,'pca',params.pca);
else
    out = getData(dataCon,cells,params.CorrelationType);
end
