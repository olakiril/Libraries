function [AreaTun AreaParams] = areaTuning(AreaTun,AreaParams,CellPos,varargin)

% function clusterTuning(CellPos)
%
% Calculates the tuning for orientation and direction depending on
% clustering
%
% areaCellsPo:

% 2009-02-24 MF


params.Area = 100;

params = paramInfo(params,varargin);

areaCellsPo = [];
areaCellsDm = [];
areaSinglePo = [];
areaSingleDm = [];
areaOriDifPo = [];
areaOriDifDm = [];
celPoCur = CellPos.CelPo;
celPoCur(AreaParams.idx) = [];
celDmCur = CellPos.CelDm;
celDmCur(AreaParams.idx) = [];
inAreaCells = AreaParams.CelDistNew<params.Area;
areaOri = celPoCur(inAreaCells);
areaDm = celDmCur(inAreaCells);

for k = 1:length(areaOri)

    areaOrispacePo = areaOri(k)+[pi 0 -pi];
    areaOrispaceDm = areaDm(k)+[2*pi 0 -2*pi];

    areaOriDifPo = [areaOriDifPo min(abs(bsxfun(@minus,areaOrispacePo',areaOri(k+1:end))))];
    areaOriDifDm = [areaOriDifDm min(abs(bsxfun(@minus,areaOrispaceDm',areaDm(k+1:end))))];

end



areaDifCellsPo = mean(areaOriDifPo);
areaDifCellsDm = mean(areaOriDifDm);

    areaDifPo = mean(AreaParams.OriDifPoNew(inAreaCells));
    areaDifDm = mean(AreaParams.OriDifDmNew(inAreaCells));

% get rid of cells with no neighbours

if isnan(areaDifCellsPo) || isnan(areaDifCellsDm)

    AreaTun.CellId(AreaParams.idx-AreaParams.idxCells) = [];
    AreaParams.idxCells = AreaParams.idxCells+1;

else

    AreaTun.areaCellsPo = [AreaTun.areaCellsPo areaDifCellsPo];
    AreaTun.areaCellsDm = [AreaTun.areaCellsDm areaDifCellsDm];

    AreaTun.areaSinglePo = [AreaTun.areaSinglePo areaDifPo];
    AreaTun.areaSingleDm = [AreaTun.areaSingleDm areaDifDm];

end








