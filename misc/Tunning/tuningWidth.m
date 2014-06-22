function  Width = tuningWidth(days,varargin)

% function  Width =tuningWidth(days,varargin)
%
% gives tuning width for all the cells.
% tuning width 1/k of the fitVonMises function
%
% Output "Width" is a structure with the width of the tuning and the cell ids
%
% 2009/2/23 MF
% MF 2009-04-25


params.CorrelationType = 'RevCorrStats';
params.Thr = 0.05;
params.spatialFreq = 0;
params.contrast = 0;
params.dprime = 1;
params.input = 'day';

params = getParams(params,varargin);

if params.dprime
    params.Poti = 'Pdoti';
    params.Pdti = 'Pddti';
else
    params.Poti = 'Poti';
    params.Pdti = 'Pdti';
end

% get DAta
fc = getObjectData(days,params);

% fit Von Mises
area = getAreaMatrixMean(fc);
fitVM = zeros(size(area,1),5);
for k = 1:size(area,1)
    fitVM(k,:) = fitVonMises(area(k,:),0:45:315);
end

% calculate width
fitVonMisesWidth = (1 ./ fitVM(:,1))';
tuningWidth = fitVonMisesWidth;
cellId= getRefId(fc);
pOti = getIndex(fc, params.Poti);
dprime = getIndex(fc,'dPrimeOri');

% Keep the significant only
sPoti = pOti<params.Thr;
Width.tuningWidth = tuningWidth(sPoti);
Width.cellId = cellId(sPoti);
Width.dprime = dprime(sPoti);


