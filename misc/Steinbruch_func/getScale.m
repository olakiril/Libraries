function scale = getScale(site)

% function scale = getScale(site)
%
% gets the scale of a site (pixels to microns conversion)
%
%MF 2009-08-07

global dataCon
sessMan = getContext(dataCon,'Session');

mag = findMetaDataVec(sessMan,site,'mag'); 
lens = findMetaDataVec(sessMan,site,'lens');

scale = 15000/512 ./ mag ./ lens;