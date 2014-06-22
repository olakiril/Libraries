function siteSize = getSiteSize(sites)

global dataCon

siteSize = zeros(length(sites),2);

for i = 1:length(sites)
    siteFile = getSiteFile(getElementById(dataCon,sites(i)));
    image = siteFile.meanCh1;
    siteSize(i,:) = size(image);
end

% output x y
siteSize = fliplr(siteSize);