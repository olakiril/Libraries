addpath(getLocalPath('/lab/libraries/commons'))
addpath(getLocalPath('/lab/libraries/datajoint-matlab'))
addpath(getLocalPath('/lab/libraries/commons/schemas'))
addpath(getLocalPath('/lab/libraries/commons/lib'))

cd(getLocalPath('/lab/libraries/mym_distribution'))
mymSetup

cd(getLocalPath('/lab/libraries/commons'))

setenv('DJ_HOST','at-database.neusc.bcm.tmc.edu:3306')

setenv('DJ_USER','cathryn')

setenv('DJ_PASS','cathryn')

mice.GUIs.Menu