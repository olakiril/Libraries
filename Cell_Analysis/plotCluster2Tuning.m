function plotCluster2Tuning(days,X,Y,varargin)

% function plotCluster2Tuning(days,X,Y,varargin)
%
% plots varius correlations between a cell and the cells around it
%
% X & Y can take :
%
% 'areaVectors'      : effective tunning of all the sourounding cells
%                       (see clusterTuning and souroundTuning)
% 'areaCluster'      : difference of tuning between the cell and the ones
%                       sourounding it and between all the sourounding cells
%                       (see clusterTuning)
% 'areaDprime'       : mean dPrime of the souround cells
% 'dPrime'           : dPrime of tuning 
% 'width'            : width of tuning
% 'contrastResponse' : offset and angle of two different contrast responses
%
% PARAMETERS
%
% params.Thr = 0.05;
% params.CorrelationType = 'RevCorrStats';
% params.luminance = 0;
% params.contrast = 0;
% params.dprime = 0;
% params.sites = 0;
% params.Area = 100;
% params.TuningWidth = 0;
% params.oti = 0;
% params.contrast = [0.1 0.5];
% params.vectorizedArea = 0;
%
% 2009-02-25 MF
% MF 2009-05-03

params.Thr = 0.05;
params.CorrelationType = 'RevCorrStats';
params.luminance = 0;
params.contrast = 0;
params.dprime = 0;
params.sites = 0;
params.Area = 100;
params.TuningWidth = 0;
params.oti = 0;
params.contrast = [0.1 0.5];
params.vectorizedArea = 0;
params.depth = 0;
params.XYinput = {X;Y};

params = getParams(params,varargin);

if ~isstruct(days)
    Cluster2Tuning = cluster2Tuning(days,params);
else
    Cluster2Tuning = days;
end

Width = Cluster2Tuning.Width;
contResp = Cluster2Tuning.contResp;
Site = Cluster2Tuning.Site;
MeanInensity = struct(Cluster2Tuning.MeanIntensity);


%% get input's data

if strmatch('meanIntensity',{X,Y})
    Response{strmatch('meanIntensity',{X,Y}),1} = [MeanInensity.meanValue];
    Name{strmatch('width',{X,Y}),1} = 'Mean Intensity';
end

if strmatch('width',{X,Y})
    Response{strmatch('width',{X,Y}),1} = Width.tuningWidth;
    Name{strmatch('width',{X,Y}),1} = 'Tuning Width';
end

if strmatch('dPrime',{X,Y})
    Response{strmatch('dPrime',{X,Y}),1} = Width.dprime;
    Name{strmatch('dPrime',{X,Y}),1} = 'dPrime';
end

if strmatch('contrastResponse',{X,Y})
    ind = strmatch('contrastResponse',{X,Y});
    Response{ind,1} = contResp.offset';
    Response{ind,2} = contResp.angle';
    Name{ind,1} = {'Contrast Response offset'};
    Name{ind,2} = {'Contrast Response angle'};
end

if strmatch('areaCluster',{X,Y})
    ind = strmatch('areaCluster',{X,Y});
    Response{ind,1} = Site.areaSinglePo;
    Response{ind,2} = Site.areaSingleDm;
    Response{ind,3} = Site.areaCellsPo;
    Response{ind,4} = Site.areaCellsDm;
    Name{ind,1} = {'PO difference'; 'from souround cells'};
    Name{ind,2} = {'DM difference';'from souround cells'};
    Name{ind,3} = {'PO difference';' of the souround cells'};
    Name{ind,4} = {'DM difference ';'of the souround cells'};
end

if strmatch('areaDprime',{X,Y})
    Response{strmatch('areaDprime',{X,Y}),1} = Site.CelOti;
    Name{strmatch('areaDprime',{X,Y}),1} = {'mean souround dPrime'};
end

if strmatch('areaVectors',{X,Y})
    ind = strmatch('areaVectors',{X,Y});
    Response{ind,1} = Site.otiNewPo;
    Response{ind,2} = Site.otiNewDm;
    Response{ind,3} = Site.poNew;
    Response{ind,4} = Site.dmNew;
    Name{ind,1} = {'resultant vector ';'of orientation TI length'};
    Name{ind,2} = {'resultant vector ';'of direction TI length'};
    Name{ind,3} = {'resultant vector';' of orientation TI angle'};
    Name{ind,4} = {'resultant vector ';'of direction TI angle'};
end

% assign X, Y values
RespIndx = zeros(1,size(Response,2)*size(Response,1));
for i = 1:size(Response,2)*size(Response,1)
    RespIndx(i) = length(Response{i});
end
respIndex = reshape( RespIndx>0,2,[]);

%% Output

% calculate the number of subplots required
Ylength = sum(respIndex(2,:));
Xlength = sum(respIndex(1,:));

subXsize = ceil(Ylength*Xlength/2);
subYsize = Ylength*Xlength/subXsize;

% plot all
figure;
indx = 0;
for i = 1:Ylength
    for k = 1:Xlength
        indx = indx +1;
        subplot(subYsize,subXsize,indx);
        regressPlot(Response{1,k},Response{2,i});
        ylabel(Name{2,i})
        xlabel(Name{1,k})
    end
end




