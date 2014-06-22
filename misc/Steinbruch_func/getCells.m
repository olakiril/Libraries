function cells = getCells(day)

% function cells = getCells(day)
%
% gets cells fast, using alexs mofified version

% MF 2009-08-06

global dataCon
sessMan = getContext(dataCon,'Session');

try
    % see if input is site
    getElementById(dataCon,day(1));
    cells = filterElementByType(sessMan,'Cell',day);
catch
    fun = @(e) strcmp(getMetaData(e,'mouseId'),day);
    mouseId = filterElementByFun(sessMan,'Subject',fun);
    cells = filterElementByType(sessMan,'Cell',mouseId);
end