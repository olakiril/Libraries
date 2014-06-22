function SourTun = souroundTuning(SourTun,CellPos,AreaParams,varargin)

% function [otiNew poNew] = souroundTuning(po,oti,dist)
%
% Calculates the resultant vector length and angle of all the sourounding
% cells. Length for each cell is considered as the tuning index devided to
% the distance from that cell.

% 2009-02-25 MF


params.AreaEffect = 1;

params = getParams(params,varargin);

po = CellPos.CelPo .* 2;
dm = CellPos.CelDm;
oti = CellPos.Oti;
% poCurr = po(AreaParams.idx);
% dmCurr = dm(AreaParams.idx);
po(AreaParams.idx) = [];
dm(AreaParams.idx) = [];
oti(AreaParams.idx) = [];
dist = AreaParams.CelDistNew;


otiNewPo =oti(1)/dist(1)^params.AreaEffect;
otiNewDm =oti(1)/dist(1)^params.AreaEffect;
poNew = po(1);
dmNew = dm(1);

for i = 2:length(po)
    
    otiOldPo = otiNewPo;
    
    otiNewPo = sqrt((otiNewPo)^2 + (oti(i)/dist(i)^params.AreaEffect)^2 - 2 * ...
    (otiNewPo) * (oti(i)/dist(i)^params.AreaEffect) * cos(poNew-po(i)));

    poNew = acos((otiNewPo^2 + otiOldPo^2 - (oti(i) / dist(i)^params.AreaEffect)^2) ...
        / 2 * otiNewPo * otiOldPo);
    
    otiOldDm = otiNewDm;
    
    otiNewDm = sqrt(( otiOldDm)^2 + (oti(i)/dist(i)^params.AreaEffect)^2 - 2 * ...
    ( otiOldDm) * (oti(i)/dist(i)^params.AreaEffect) * cos(dmNew-po(i)));

    dmNew = acos((otiNewDm^2 + otiOldDm^2 - (oti(i) / dist(i)^params.AreaEffect)^2) ...
        / 2 * otiNewDm * otiOldDm);
    
end

SourTun.otiNewPo = [SourTun.otiNewPo otiNewPo];
SourTun.poNew = [SourTun.poNew abs((poNew / 2)-AreaParams.CelPo)];
SourTun.otiNewDm = [SourTun.otiNewDm otiNewDm];
SourTun.dmNew = [SourTun.dmNew abs(dmNew - AreaParams.CelDm)];
