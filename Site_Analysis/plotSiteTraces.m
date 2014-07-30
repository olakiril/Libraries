function plotSiteTraces(siteId,varargin)

% function plotSite(site,varargin)
%
%  Visualize the activity of all the traces for a site
%
% MF 2009-09-01

params.thr = 0.05;
params.dprime = 0 ;
params.dir = 0;
params.transperancy = 0;
params.neuropil = 0;

params = getParams(params,varargin);

global dataCon
sessMan = getContext(dataCon,'Session');

% get data
neuropil = filterElementByType(sessMan,'Neuropil',siteId);
cells = filterElementByType(sessMan,'Cell',siteId);
neuroglia = filterElementByType(sessMan,'Neuroglia',siteId);
ids = [neuropil, cells, neuroglia];

mask =getData(dataCon,siteId,'Image','type','mask');
ch1 = struct(getData(dataCon,siteId,'Image','type','ch1'));

fc = getObjectData(cells,'input','cells',params);

% use dprime or oti
if params.dprime
    parPoti = 'Pdoti';
    parPdti = 'Pddti';
    maxOtis = getIndex(fc,'dPrimeOri');
    maxDtis = getIndex(fc,'dPrimeDm');
else
    parPoti = 'Poti';
    parPdti = 'Pdti';
    maxOtis = getVonMises(fc,2);
    maxDtis = getVonMises(fc,1);
end

% do it for orientation or direction
if params.dir
    params.pTi = parPdti;
    vonMissesIndex = 4;
    params.direction = 'Direction';
    angCon = 360/(2*pi);
    ang = 360;
    maxOtis = maxDtis;
    set(gcf,'RendererMode','manual')
    set(gcf,'Renderer','OpenGL')
else
    params.pTi = parPoti;
    vonMissesIndex = 3;
    params.direction = 'Orientation';
    angCon = 180/(pi);
    ang = 180;
end

pOti = getIndex(fc,params.pTi);
prOri = getVonMises(fc,vonMissesIndex);

maskNum = findMetaDataVec(sessMan,ids,'maskNum');
im = getImage(mask);

imOti = im*0;
imPo = im*0;

maxOti = max(maxOtis);

% Exchange the cell values of the mask with the Oti or Dti
for i = 1:length(fc)
    if pOti(i)<params.thr
        k = maskNum(ids==cells(i));
        imOti((im==k))= maxOtis(i)/maxOti;
        imPo((im==k))= prOri(i); 
    end
end

% Some necessary stuff to get a stable B/W image of the site
v = mean(ch1.image,3);
v = (v - min(min(v)))/(max(max(v))-min(min(v)));
imPos = imPo.*angCon;

if ~params.transperancy
    imOti = imOti>0;
end

% plot
s  = (imOti);
h = (imPos./ang);
image(hsv2rgb(cat(3,h,cat(3,s,v))));
colormap(hsv(ang));
colorbar('location','southoutside');
axis off




