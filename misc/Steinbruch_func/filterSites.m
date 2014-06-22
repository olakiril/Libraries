function newSites = filterSites(sites,varargin)

% function newSites = filterSites(sites,varargin)
%
%  filters sites by the experiment type
% input and  output is site Ids
%
% MF 2009-05-14

params.experiment = 0;

params = getParams(params,varargin);

global dataCon;
sessMan = getContext(dataCon,'Session');

keepSite = zeros(1,length(sites));

for i = 1:length(sites)
    expType = findMetaData(sessMan,sites(i),'experiment');
    keepSite(i) = strncmpi(expType,params.experiment,6);
end

newSites = sites(logical(keepSite));