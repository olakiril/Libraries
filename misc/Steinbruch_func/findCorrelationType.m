function correlationType = findCorrelationType(site)

% function correlationType = findCorrelationType(sessMan,site)
%
% finds proper Analysis object
%
% MF 2009-08-07

global dataCon
sessMan = getContext(dataCon,'Session');

 expType = findMetaData(sessMan,site,'expType');
 
 if strcmp(expType,'MultDimExperiment')
     correlationType = 'RevCorrStats';
 else
     correlationType = 'ForwardCorrelation';
 end
 
 