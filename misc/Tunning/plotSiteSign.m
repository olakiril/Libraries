function  [pOtiMean prcSign daylength] = plotSiteSign(days,varargin)

% function  plotSiteSign(day,varargin)
%
% gives out the mean OTI and % Significanse of the sites
% 
% MF 2009-04-12

params.CorrelationType = 'RevCorrStats';
params.Thr = 0.05;
params.spatialFreq = 0;
params.contrast = 0;
params.dprime = 0;
params.Bin = 8;
params.dir = 0;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

global dataCon;
sessMan = getContext(dataCon,'Session');

% use dprime or oti 
if params.dprime
    parPoti = 'Pdoti';
    parPdti = 'Pddti';
else
    parPoti = 'Poti';
    parPdti = 'Pdti';
end

% do it for orientation or direction
if params.dir
    vonMissesIndex = 4;
    params.Poti = parPdti;
else
    vonMissesIndex = 3;
    params.Poti = parPoti;
end

sitesDay = cell(1,size(days,1));
daylength = zeros(1,size(days,1));

for i = 1:size(days,1)
    sitesDay{i} = filterElementByMeta(sessMan,'Site','mouseId',days(i,:));
    daylength(i) = length(sitesDay{i});
end

sites = cell2mat(sitesDay);

ThrIndex = cell(1,length(sites));
POti = cell(1,length(sites));
POri = cell(1,length(sites));
siteLength = zeros(1,length(sites));

% get data
for n = 1: length(sites)

    site = sites(n);
    cells = filterElementByType(sessMan,'Cell',site);
    fc = getData(dataCon,cells,params.CorrelationType,'spatialFreq',params.spatialFreq,'contrast',params.contrast);
    indx = zeros(length(fc),1);

    % Find index for faulty cells
    for i = 1:length(fc)
        oti = getPoti(fc,i);
        if isempty(oti)
            indx(i) = i;
        end
    end

    indx = nonzeros(indx);
    pOriAll = getVonMises(fc,vonMissesIndex,indx);
    pOtiAll = getIndex(fc, params.Poti,indx);
    ThrIndex{n} = pOtiAll <= params.Thr;
    POti{n} = pOtiAll(ThrIndex{n});
    POri{n} = pOriAll(ThrIndex{n});
    siteLength(n) = length(POti{n});

end

pOtiMean = zeros(1,length(POti));
prcSign = zeros(1,length(POti));

for i = 1:length(POti)
    pOtiMean(i) = mean(POti{i});
    % Calculate the percentage of significantly tunned cells
    prcSign(i) = length(POti{i})/length(ThrIndex{i});
end







