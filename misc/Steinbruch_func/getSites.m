function sites = getSites(day,varargin)

% function cells = getCells(day,varargin)
%
% gets cells fast, using alexs mofified version
% it also has the option of filtering by experiment if experiment type is
% given
%
% MF 2009-08-06

global dataCon
sessMan = getContext(dataCon,'Session');

fun = @(e) strcmp(getMetaData(e,'mouseId'),day);
mouseId = filterElementByFun(sessMan,'Subject',fun);
sites = filterElementByType(sessMan,'Site',mouseId);


% filter by experiment if input is given
if ~isempty(varargin)
    for i = 1:size(sites,2)
         siteExp{i} = findMetaData(sessMan,sites(i),'experiment');
    end  
    sites = sites(strncmpi(siteExp,varargin,size(varargin{1},2)));
end
