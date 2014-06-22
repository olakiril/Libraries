function histSitePreference (site,varargin)

% function histSitePreference (site)
%
% plots the orientation preference histogram of all the cells of a site
% 
% if multiple sites are given you will have a multiplot
%
% if only one site is given there is going to be also the picture of the
% site and its cells
%
% MF 2009-08-08

params.thr = 0.05;
params.dprime = 0;
params.Bin = 8;
params.dir = 0;
params.print = 0;
params.neuropil = 0;

params = getParams(params,varargin);

global dataCon
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
    xlab = 'Binned Directions';
    params.pTi = parPdti;
    p = 2*pi;
    params.direction = 'Direction';
else
    vonMissesIndex = 3;
    xlab = 'Binned Orientations';
    params.pTi = parPoti;
    p = pi;
    params.direction = 'Orientation';
end

conditionNum = length(site);
xsize = ceil(sqrt(conditionNum));
ysize = ceil(conditionNum/xsize);

if conditionNum ==1
    subplot(122)
    plotSiteRaw(site,params)
    xsize = xsize+1;
end

bcents = linspace(0,p,9);
bcents = .5*(bcents(1:end-1) + bcents(2:end));

for i = 1:conditionNum
    cells = filterElementByType(sessMan,'Cell',site(i));
    fc = getObjectData(cells,'input','cells',params);
    pOti = getIndex(fc,params.pTi);
    prOri = getVonMises(fc, vonMissesIndex);
    signCells = prOri(pOti<params.thr);
    sign = sum(pOti<params.thr)/length(pOti);
         
    subplot(ysize,xsize,i)
    
    hist(signCells ,bcents)
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','b','EdgeColor','w')
   
    title({['siteId: ' num2str(site(i))]; [' %Sign.Tun : ' num2str(round(sign*100)) '%'];['Total#Cells : ' num2str(length(cells))]})
    
    set(gca,'box','off')
    xlim([0 p])
    set(gca,'XTick',bcents)
    set(gca,'XTickLabel',round(bcents/pi*(180)))
    
    xlabel(gca,xlab);
    ylabel(gca,'# of cells');
    
end

set(gcf,'Color',[1 1 1]);

if params.print
    print('-dpng',num2str(site(1)));
    clf
end
    



