function plotDensityCluster(site,varargin)

% function plotDensityCluster(site)
%
% plots the density spread of preference versus distance of a site
%
% MF 2009-08-10


params.Thr = 0.05;
params.CorrelationType = 'RevCorrStats';
params.dprime = 0;
params.sites = 0;
params.vertical = 0;
params.input = 'site';
params.direction = 0;

params = getParams(params,varargin);

SitePos = clusterFind(site,params);

if ~params.direction
    figure ('Name','Po');    
    densityDir(SitePos.CelDist,SitePos.OriDifPo);
    title(['siteId: ' num2str(site)])
    ylabel(gca,'orientational difference');
    xlabel(gca,'microns ');
else
    figure('Name','Dm');   
    densityDir(SitePos.CelDist,SitePos.OriDifDm,'cont',40);
    title(['siteId: ' num2str(site)])
    ylabel(gca,'directional difference');
    xlabel(gca,'microns ');
end

set(gcf,'Color',[1 1 1]);