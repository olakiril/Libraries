function siteId = getSiteId(siteName)

% function siteId = getSiteId(siteName)
%
% finds SiteId from site Name fast
%
% MF 2009-12-28


global dataCon
sessMan = getContext(dataCon,'Session');

day = [siteName(1:6) '_001'];
sites = getSites(day);
day = getParent(sessMan,sites(end));
siteId = getElementByMeta(sessMan,day,'Site','datafile',siteName);