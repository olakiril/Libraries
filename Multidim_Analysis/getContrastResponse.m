function GetContrastResponse = getContrastResponse(days,varargin)

% function getContrastResponse = contrastResponse(day,varargin)
%
% Calculates the offset and slope of two different contrast responses
%
% MF 2009-04-26

params.CorrelationType = 'RevCorrStats';
params.Thr = 0.05;
params.contrast = [0.1 0.5];
params.dprime = 0;
params.collapse =1;
params.Bin = 8;
params.error = 1;
params.normalize = 1;
params.sigcell = 1;
params.sites  = 0;
params.DFoF = 0;
params.scatter = 1;
params.spatialFreq = 0;
params.input = 'day';

params = getParams(params,varargin);

data = getObjectData(days,params);

ConCorr = conCorr(data,params);

reg = zeros(length(ConCorr.CellId),2);

for i = 1:length(ConCorr.CellId)
    reg(i,:)= regressPlot(ConCorr.DFoF{1}(i,:),ConCorr.DFoF{2}(i,:),'plot',0);
end

GetContrastResponse.offset = reg(:,1);
GetContrastResponse.angle = reg(:,2);
GetContrastResponse.CellId = ConCorr.CellId;





