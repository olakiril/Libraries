function SitePos = clusterFind(site,varargin)

% function clusterFind(CellPos)
%
% Calculates the clustering of tuning for orientation and direction
% CelPo: Prefered orientation
% CelDm: Prefered direction
% CelDist: Difference in micrometers
% OriDifPo: Difference in prefered orientation
% OriDifDm: Difference in prefered direction

% 2009-02-24 MF
% 2009-04-25 MF


params.Thr = 0.05;
params.CorrelationType = 'RevCorrStats';
params.spatialFreq = 0;
params.contrast = 0;
params.dprime = 1;
params.sites = 0;
params.vertical = 0;

params = getParams(params,varargin);

% Get the data
CellPos = multiSitePos(site,params);

CelDist = cell(1,length(CellPos.CelCoox));
OriDifPo = cell(1,length(CellPos.CelCoox));
OriDifDm = cell(1,length(CellPos.CelCoox));

for i = 1:length(CellPos.CelCoox)
    
    % Find the difrences in distance
    if ~params.vertical
        CelDistNew = sqrt((sqrt((CellPos.CelCoox(i+1:end)-CellPos.CelCoox(i)).^2 + ...
            (CellPos.CelCooy(i+1:end)-CellPos.CelCooy(i)).^2)).^2+(CellPos.CelCooz(i+1:end)-CellPos.CelCooz(i)).^2);
    else
        CelDistNew = CellPos.CelCooz(i+1:end)-CellPos.CelCooz(i);
    end
    CelDist{i} = CelDistNew;

    % Find the difrences in tuning
    OrispacePo = CellPos.CelPo(i)+[pi 0 -pi];
    OrispaceDm = CellPos.CelDm(i)+[2*pi 0 -2*pi];

    OriDifPoNew = min(abs(bsxfun(@minus,OrispacePo',CellPos.CelPo(i+1:end))));
    OriDifPo{i} = OriDifPoNew;

    OriDifDmNew = min(abs(bsxfun(@minus,OrispaceDm',CellPos.CelDm(i+1:end))));
    OriDifDm{i} = OriDifDmNew;

end


% put everything into a output structure

SitePos.CelPo = CellPos.CelPo;
SitePos.CelDm = CellPos.CelDm;
SitePos.CelDist = cell2mat(CelDist);
SitePos.OriDifPo = cell2mat(OriDifPo);
SitePos.OriDifDm = cell2mat(OriDifDm);



