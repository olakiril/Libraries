function CellPos =  multiSitePos(days,varargin)

% function CellPos =  multiSitePos(day,varargin)
%
% finds the relative possitions of the cells and their tuning
%
% MF 2009-2-19
% MF 2009-4-25

params.Thr = 0.05;
params.CorrelationType = 'RevCorrStats';
params.spatialFreq = 0;
params.contrast = 0;
params.dprime = 0;
params.site = 0;

params = getParams(params,varargin);

global dataCon;
sessMan = getContext(dataCon,'Session');

% use dprime or oti 
if params.dprime
    parPoti = 'Pdoti';
else
    parPoti = 'Poti';
end

% Get Data
data = getObjectData(days,params);
cellIds = getRefId(data);
siteIds = getAncestorByType(sessMan,cellIds,'Site');
sites = unique(siteIds);

% Initialize
celCoox = cell(1,length(sites));
celCooy = cell(1,length(sites));
celCooz = cell(1,length(sites));
celPo = cell(1,length(sites));
celDm = cell(1,length(sites));
cellId = cell(1,length(sites));
oti = cell(1,length(sites));

% Loop through the sites
for p = 1:length(sites)

    % get data
    siteId = (sites(p));
    neuropil = filterElementByType(sessMan,'Neuropil',siteId);
    cells = filterElementByType(sessMan,'Cell',siteId);
    neuroglia = filterElementByType(sessMan,'Neuroglia',siteId);
    ids = [neuropil,cells, neuroglia];
    mask =getData(dataCon,siteId,'Image','type','mask');
    maskContent = getContent(mask);
    im = maskContent.image;
    zPosSite = findMetaData(sessMan,siteId,'z');
    yPosSite = findMetaData(sessMan,siteId,'y');
    xPosSite = findMetaData(sessMan,siteId,'x');

    % initialize
    CelCoox = zeros(1,length(ids)-1);
    CelCooy = zeros(1,length(ids)-1);
    CelCooz = zeros(1,length(ids)-1);
    cellIndex = zeros(1,length(ids)-1);
  
    % get data from object
    fc = data(siteIds==sites(p));
    pTun =  getIndex(fc, parPoti);
    VMPo = getVonMises(fc,3);
    VMDm = getVonMises(fc,4);
    
    % get only the tunned
    tunedIndex = pTun < params.Thr;

    % Calculate all the rest
    if params.dprime
        tunInd = getIndex(fc,'dPrimeOri');
    else
        tunInd = getVonMises(fc,2);
    end
    
    [x,y] = meshgrid(1:size(im,2),1:size(im,1));
    
    for i = 2:length(ids)
    
        maskNum = findMetaData(sessMan,ids(i),'maskNum');
        xPos = mean(x(im==maskNum));
        yPos = mean(y(im==maskNum));
        CelCoox(i) = xPos+xPosSite;
        CelCooy(i) = yPos+yPosSite;
        CelCooz(i) = zPosSite;
        cellIndex(i) = sum(ids(i) == cells(tunedIndex));        
    end
    celCoox{p} = CelCoox(cellIndex==1);
    celCooy{p} = CelCooy(cellIndex==1);
    celCooz{p} = CelCooz(cellIndex==1);
    cellId{p} = cells(tunedIndex);
    celPo{p} = VMPo(tunedIndex);
    celDm{p} = VMDm(tunedIndex);
    oti{p} = tunInd(tunedIndex);
end

% Output structure
CellPos.CelCoox = cell2mat(celCoox);
CellPos.CelCooy = cell2mat(celCooy);
CellPos.CelCooz = cell2mat(celCooz);
CellPos.CelPo = cell2mat(celPo);
CellPos.CelDm = cell2mat(celDm);
CellPos.CellId = cell2mat(cellId);
CellPos.Oti = cell2mat(oti);



