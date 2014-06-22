function siteOverview(site)

% function siteOverview(site)
%
% find the zoomed in sites in a low magnification site
%
% MF 2008-08-08

params.mix = 1;

global dataCon
sessMan = getContext(dataCon,'Session');

%get image of the site
siteFile = getSiteFile(getElementById(dataCon,site));
image = siteFile.meanCh1;

% find all the cell containing sites that day
day = findMetaData(sessMan,site,'mouseId');
sites = getSites(day,'multiDimExp');

% % check for rotation
% for i = 1:length(sites)
%     tp = getTpReader(getElementById(dataCon,sites(i)),sessMan);
%     properties = getProperties(tp);
%     if properties.rotation~=0
%         display('rotation problem')
%         break
%     end
% end

% get the coordinates & scale & size
[xSites ySites] = getCoordinates(sites);
scale = getScale(sites);
sitesSize = getSiteSize(sites);

[xSite ySite] = getCoordinates(site);
siteScale = getScale(site);
siteSize = getSiteSize(site);

% convert pixels to microns
ySizes = zeros(1,length(sites));
xSizes = zeros(1,length(sites));
for i = 1:length(sites)
    ySizes(i) = sitesSize(i,2)*scale(i);
    xSizes(i) = sitesSize(i,1)*scale(i);
end
ySize = siteSize(2)*siteScale;
xSize = siteSize(1)*siteScale;

% find all the associated sites
indx = find((ySite - ySize/2) < ySites &  (ySite + ySize/2) > ySites & ...
    (xSite - xSize/2) < xSites &  (xSite + xSize/2) > xSites);

imagesc(image);
colormap gray

hold on

y0 = zeros(1,length(indx));
y1 = zeros(1,length(indx));
x0 = zeros(1,length(indx));
x1 = zeros(1,length(indx));

for i = 1:length(indx)
    y = (ySites(indx(i))- ySite + ySizes(indx(i))/2)/siteScale;
    y0(i) = round(siteSize(1)/2 - y);
    y1(i) = round(ySizes(indx(i))/siteScale);

    x = (xSites(indx(i))- xSite + xSizes(indx(i))/2)/siteScale;
    x0(i) = round(siteSize(1)/2 - x);
    x1(i) = round(xSizes(indx(i))/siteScale);

    rectangle('EdgeColor','r','Position',[x0(i) y0(i) x1(i) y1(i)]);
end

set(gcf,'Color',[1 1 1]);

if params.mix
    curfig = [];
    k=-1;
    iter = 0;
    while k ~=1
        k=waitforbuttonpress;
%         close(curfig)
        if k ~=1
            iter = iter+1;
            pos= get(gca,'CurrentPoint');
            text(pos(1,1),pos(1,2),num2str(iter),'color','r');
            % find sites including this possition
            idx(iter,:) = ((pos(1,1)>x0) & (pos(1,1)<(x0 + x1)) & (pos(1,2)>y0) & (pos(1,2)<(y0 + y1)));
            % plot site preference
            plotSitePref(sites(idx(iter,:)),'sites',1);
        end
        curfig = gcf;
    end
    plotSitePref(sites(idx(k,:)),'sites',1);
    figure;
    histSitePreference(sites(idx(k,:)));



end













