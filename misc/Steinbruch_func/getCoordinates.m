function [x y z] = getCoordinates(site)

% function [x y z] = getCoordinates(site)
%
% gets all three coordinates
%
% MF 2009-08-07

global dataCon
sessMan = getContext(dataCon,'Session');

x = cell2mat(findMetaDataVec(sessMan,site,'x','UniformOutput',0));
y = cell2mat(findMetaDataVec(sessMan,site,'y','UniformOutput',0));
z = cell2mat(findMetaDataVec(sessMan,site,'y','UniformOutput',0));

