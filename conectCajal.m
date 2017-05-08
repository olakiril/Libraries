if strcmp(computer,'PCWIN64')
    addpath(('Z:/libraries/mym_distribution'));mymSetup
    % setPathExt
    % addpath(getLocalPath('/lab/users\Manolis/Cajal/datajoint-matlab'))
    addpath_recurse(([getenv('HOMEDRIVE') getenv('HOMEPATH') '\Documents\github\datajoint-matlab']))
    % addpath_recurse(getLocalPath('/lab/users\Manolis/Cajal/pipeline/matlab/'))
    addpath_recurse(([getenv('HOMEDRIVE') getenv('HOMEPATH') '\Documents\github\pipeline\matlab']))
    addpath_recurse(([getenv('HOMEDRIVE') getenv('HOMEPATH') '\Documents\github\']))
    % addpath_recurse(getLocalPath('/lab/users\Manolis/Cajal/commons'))
elseif strcmp(computer,'MACI64')
%     run ~/mym/mymSetu
    run('/Volumes/lab/libraries/mym_distribution/mymSetup.m')
    addpath('~/github/datajoint-matlab/')
    addpath_recurse('~/github/pipeline/')
    addpath_recurse('~/github/commons/')
    addpath('~/github/PyMouse/matlab/')
end

setenv('DJ_HOST','at-database.ad.bcm.edu:3306')
setenv('DJ_USER','manolis')
setenv('DJ_PASS','manolis#1')
