addpath(getLocalPath('/lab/libraries/mym_distribution'));
mymSetup

addpath(getLocalPath('/lab/users/Manolis/GitHub/datajoint-matlab/'))
addpath(getLocalPath('/lab/users/Manolis/Matlab/Datajoint2/'))

setenv('DJ_HOST','127.0.0.1:3306')

setenv('DJ_USER','root')

% setenv('DJ_PASS','root')

import vis2p.*