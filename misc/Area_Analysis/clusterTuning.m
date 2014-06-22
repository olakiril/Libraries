function SitePos = clusterTuning(site,varargin)

% function SitePos = clusterTuning(site,varargin)
%
% Calculates the tuning for orientation and direction depending on
% clustering. Only applies for sites from the same day
%
% OUTPUT
%
% SitePos.CellId        : Cell Ids
% SitePos.areaSinglePo  : Prefered orientation differnce from all the
%                           other cells in an area
% SitePos.areaSingleDm  : Prefered direction differnce from all the
%                           other cells in an area
% SitePos.areaCellsPo   : Prefered orientation differnce of all the
%                           other cells in an area
% SitePos.areaCellsDm   : Prefered direction differnce of all the
%                           other cells in an area
% SitePos.CelOti        : Oti or dprime
% SitePos.otiNewPo      : Resultant vector length of all the sourrounding
%                           cells OTI's
% SitePos.poNew         : Resultant vector angle of all the sourrounding
%                           cells OTI's
% SitePos.otiNewDm      : Resultant vector length of all the sourrounding
%                           cells OTI's
% SitePos.dmNew         : Resultant vector angle of all the sourrounding
%                           cells OTI's
%
% 2009-02-24 MF
% 2009-05-01 MF

params.Thr = 0.05;
params.CorrelationType = 'RevCorrStats';
params.luminance = 0;
params.contrast = 0;
params.dprime = 1;
params.sites = 0;
params.Area = 100;
params.AreaEffect = 1;
params.vectorizedArea = 0;
params.depth = 0;

params = getParams(params,varargin);

% Get the possitions and the prefferences of all the cells
CellPos = multiSitePos(site,params);

% Initialize
AreaParams.idxCells = 0;
SourTun.otiNewPo = [];
SourTun.poNew = [];
SourTun.otiNewDm = [];
SourTun.dmNew = [];
OriDifPo = cell(1,length(CellPos.CelCoox));
OriDifDm = cell(1,length(CellPos.CelCoox));
areaCellsPo = cell(1,length(CellPos.CelCoox));
areaCellsDm = cell(1,length(CellPos.CelCoox));
areaSinglePo = cell(1,length(CellPos.CelCoox));
areaSingleDm = cell(1,length(CellPos.CelCoox));
CelOti = cell(1,length(CellPos.CelCoox));

% Loop through all the cells
for i = 1:length(CellPos.CelCoox)
    % get the arrays for all the cells
    CelPoArray = CellPos.CelPo;
    CelDmArray = CellPos.CelDm;
    cellsX = CellPos.CelCoox;
    cellsZ = CellPos.CelCooz;
    cellsY = CellPos.CelCooy;

    % Assign cell's info to viariables
    AreaParams.idx = i;
    cellX = CellPos.CelCoox(i);
    cellY = CellPos.CelCooy(i);
    cellZ = CellPos.CelCooz(i);
    CelDm = CellPos.CelDm(i);
    CelPo = CellPos.CelPo(i);
    AreaParams.CelPo = CelPo;
    AreaParams.CelDm = CelDm;

    % remove cell's data from the arrays
    CelPoArray(i) = [];
    CelDmArray(i) = [];
    cellsZ(i) = [];
    cellsY(i) = [];
    cellsX(i) = [];

    % Calculate the distances between the chosen cell and all the other cells
    if ~params.depth
        AreaParams.CelDistNew = sqrt((sqrt((cellsX-cellX).^2 + ...
            (cellsY-cellY).^2)).^2+(cellsZ-cellZ).^2);
    else
        AreaParams.CelDistNew = cellsZ-cellZ;
    end

    % Create all the possible orientations and directions and choose the
    % ones that have the minimum difference (because of the circular space)
    OrispacePo = CelPo + [pi 0 -pi];
    OrispaceDm = CelDm + [2*pi 0 -2*pi];
    OriDifPo{i} = min(abs(bsxfun(@minus,OrispacePo',CelPoArray)));
    OriDifDm{i} = min(abs(bsxfun(@minus,OrispaceDm',CelDmArray)));

    % Specified area with the sourounding cells
    % get the arrays
    celPoCur = CellPos.CelPo;
    celDmCur = CellPos.CelDm;
    celOtiAll = CellPos.Oti;

    % delete the cell's elements
    celDmCur(i) = [];
    celPoCur(i) = [];
    celOtiAll(i) = [];
    if params.Area
        % Find the cells inside the specified area
        inAreaCells = AreaParams.CelDistNew<params.Area;
        areaOri = celPoCur(inAreaCells);
        areaDm = celDmCur(inAreaCells);
        celOti = celOtiAll(inAreaCells);

        % some preallocations
        areaOriDifPo = cell(1,length(areaOri));
        areaOriDifDm = cell(1,length(areaOri));

        % loop through all the cells of the specified area and find the
        % differences between all the cells
        for k = 1:length(areaOri)
            % create circular space and choose the smallest difference
            areaOrispacePo = areaOri(k)+[pi 0 -pi];
            areaOrispaceDm = areaDm(k)+[2*pi 0 -2*pi];
            areaOriDifPo{k} = min(abs(bsxfun(@minus,areaOrispacePo',areaOri(k+1:end))));
            areaOriDifDm{k} = min(abs(bsxfun(@minus,areaOrispaceDm',areaDm(k+1:end))));
        end

        % Mean difference OF the sourround cells
        areaDifCellsPo = mean(cell2mat(areaOriDifPo));
        areaDifCellsDm = mean(cell2mat(areaOriDifDm));

        % Mean difference FROM the sourround cells
        areaDifPo = mean(OriDifPo{i}(inAreaCells));
        areaDifDm = mean( OriDifDm{i}(inAreaCells));

        % get rid of cells with no neighbours
        if isnan(areaDifCellsPo) || isnan(areaDifCellsDm)
            CellPos.CellId(i-AreaParams.idxCells) = [];
            AreaParams.idxCells = AreaParams.idxCells+1;
        else
            areaCellsPo{i} = areaDifCellsPo;
            areaCellsDm{i} = areaDifCellsDm;
            areaSinglePo{i} = areaDifPo;
            areaSingleDm{i} = areaDifDm;
            CelOti{i} = mean(celOti);
        end
    end
    if ~params.Area || params.vectorizedArea
        % calculate the tunning of all the souround cells
        SourTun = souroundTuning(SourTun,CellPos, AreaParams,'AreaEffect',params.AreaEffect);
    end
end

% put everything into a output structure
SitePos.CellId = CellPos.CellId;
SitePos.areaSinglePo = cell2mat(areaSinglePo);
SitePos.areaSingleDm = cell2mat(areaSingleDm);
SitePos.areaCellsPo = cell2mat(areaCellsPo);
SitePos.areaCellsDm = cell2mat(areaCellsDm);
SitePos.CelOti = cell2mat(CelOti);
SitePos.otiNewPo = SourTun.otiNewPo;
SitePos.poNew = SourTun.poNew ;
SitePos.otiNewDm = SourTun.otiNewDm;
SitePos.dmNew = SourTun.dmNew;







