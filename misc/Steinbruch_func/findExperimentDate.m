function FindExperimentDate = findExperimentDate(exp)

% function FindExperimentDate = findExperimentDate(exp)
%
% finds sites, dates where the specific epxeriment was done
% 
% MF 2009-08-03

global dataCon
sessMan = getContext(dataCon,'Session');

allObjects = getElementList(dataCon);
allIds = allObjects(:,1);
allTypes = allObjects(:,2);
siteIds = cell2mat(allIds(strcmp(allTypes,'Site')));

siteExp = cell(1,size(siteIds,1));

for i = 1:size(siteIds,1)
   siteExp{i} = findMetaData(sessMan,siteIds(i),'experiment');
end

correctIds = siteIds(strncmpi(siteExp,exp,size(exp,2)));

parentIds = zeros(size(correctIds,1),1);

for i = 1:size(correctIds,1)
    parentIds(i) = getParent(sessMan,correctIds(i));
end

uParentIds = unique(parentIds);

days = findMetaDataVec(sessMan,uParentIds,'mouseId','UniformOutput',false);


FindExperimentDate.siteDays = findMetaDataVec(sessMan,parentIds,'mouseId','UniformOutput',false);
FindExperimentDate.days = days;
FindExperimentDate.sessionIds = uParentIds;
FindExperimentDate.allSessionIds = parentIds;
FindExperimentDate.siteIds = correctIds;
