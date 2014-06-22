function mouseId = getId(day)

% function cells = getCells(day,varargin)
%
% gets cells fast, using alexs mofified version
%
% MF 2009-08-06

global dataCon
sessMan = getContext(dataCon,'Session');

fun = @(e) strcmp(getMetaData(e,'mouseId'),day);
mouseId = filterElementByFun(sessMan,'Subject',fun);


