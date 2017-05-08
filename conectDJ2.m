

addpath(getLocalPath('/lab/libraries/datajoint-matlab/'))
addpath(getLocalPath('/lab/users/Manolis/Matlab/Datajoint2/'))
setenv('DJ_HOST','at-database.ad.bcm.edu:3306')
% setenv('DJ_HOST','128.249.80.229:3306')
setenv('DJ_USER','manolis')

setenv('DJ_PASS','manolis#1')

if strcmp(computer,'PCWIN64')
    addpath(getLocalPath('/lab/libraries/mym_distribution'));mymSetup
%     addpath C:\Users\Manolis\Documents\github\TIFFStack
elseif strcmp(computer,'MACI64')
    run /Volumes/lab/libraries/mym_distribution/mymSetup
else
    run ~/mym/mymSetup
end

import vis2p.*

