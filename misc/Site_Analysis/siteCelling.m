function siteCelling(siteId,varargin)
% function siteCelling(siteId,varargin)
%
%  Browse throught the activity of the cells within a site
%
% Takes a site Id
%
% MF 2008-12-05

params.thr = 0.05;
params.dprime = 0 ;
params.dir = 0;
params.transperancy = 0;
params.ids = 1;
params.multisite = [];
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
figure
s  = (imOti);
h = (imPos./ang);
image(hsv2rgb(cat(3,h,cat(3,s,v))));
colormap(hsv(ang));
colorbar('location','southoutside');
axis off

[x,y] = meshgrid(1:size(im,2),1:size(im,1));
radius = zeros(1,length(maskNum)-1);
xPos = zeros(1,length(maskNum)-1);
yPos = zeros(1,length(maskNum)-1);

for i = 2:length(maskNum)
    colapse = sum(im==maskNum(i));
    radius(i-1) = mean(colapse(colapse~=0));
    xPos(i-1) = mean(x(im==maskNum(i)));
    yPos(i-1) = mean(y(im==maskNum(i)));
end

[xu,yu] = ginput;
dist = sqrt(bsxfun( @minus, xPos, xu ).^2 + bsxfun( @minus, yPos, yu ).^2);
[dist, midx] = min(dist,[],2);
dist = dist';
midx = midx';
retIds = ids( midx( dist < radius(midx) )  + 1);
fc = getObjectData(retIds,'input','cells',params);


if params.ids
    hold on
    for i = 2:length(maskNum)
            xPos = mean(x(im==maskNum(i)));
            yPos = mean(y(im==maskNum(i)));

            if pOti(ids(i) == cells)<= params.thr
                h = text(xPos,yPos,num2str(ids(i)),'color',[0 1 0],'Fontsize',8);
            else                
                h = text(xPos,yPos,num2str(ids(i)),'color','black','Fontsize',8);
            end

            set(h,'HorizontalAlignment','Left');
            set(h,'VerticalAlignment','Top');
    end
end
   

for i = 1:length(retIds)
    figure
    if params.multisite
        comp_cells = params.multisite;
        ind = find(comp_cells == retIds(i));
        if ~isempty(ind)
            columnIndx = ceil(ind/size(comp_cells,1));
            rowIndx = ind - (columnIndx - 1) * size(comp_cells,1);
            addIds = comp_cells(rowIndx,:);
            dc = getObjectData(addIds,'input','cells',params);
            VMPlot(dc)
            subplot(311)
            plotTraces(addIds(1),params)
            subplot(312)
            plotTraces(addIds(2),params)
            subplot(313)
            plotTraces(addIds(3),params)
        else
            VMPlot(fc(i))
        end
    else
        VMPlot(fc(i))
    end
end

plotTraces(retIds,params)


