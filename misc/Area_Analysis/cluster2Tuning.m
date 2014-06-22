function Cluster2Tuning = cluster2Tuning(days,varargin)

% function Cluster2Tuning = cluster2Tuning(days,varargin)
%
% gets the data for plotCluster2Tuning
% see that for help
%
% MF 2009-05-04


params.Thr = 0.05;
params.CorrelationType = 'RevCorrStats';
params.luminance = 0;
params.contrast = 0;
params.dprime = 0;
params.sites = 0;
params.Area = 100;
params.TuningWidth = 0;
params.oti = 0;
params.contrast = 0;
params.vectorizedArea = 1;
params.depth = 0;

params = getParams(params,varargin);

global dataCon

Site = [];
Width = [];
contResp = [];
MeanIntensity = [];

% get the sites
Sites = getObjectData(days,params,'output','sites');

% get the clustering data from each day and put them together
cluster = [];
for i = 1:size(days,1)
    Cluster = clusterTuning(Sites{i},params,'contrast',0,'input','site');
    cluster = strcat(struct2cell(Cluster),cluster);
end
fieldN = fieldnames(Cluster);
Site = cell2struct(cluster,fieldN);

% get the width
Width = tuningWidth(Site.CellId,params,'contrast',0,'input','cell','Thr',1);

% get the contrast responses
if strmatch('contrastResponse',params.XYinput)
    contResp = getContrastResponse(Site.CellId,params,'input','cell','Thr',1);
end
 
% get the mean inensity
MeanIntensity = getData(dataCon,Site.CellId,'MeanIntensity');

%% output

Cluster2Tuning.Site = Site;
Cluster2Tuning.Width = Width;
Cluster2Tuning.contResp = contResp;
Cluster2Tuning.MeanIntensity = MeanIntensity;



