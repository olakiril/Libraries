setenv('DJ_HOST','at-database.ad.bcm.edu:3306')
setenv('DJ_USER','manolis')
setenv('DJ_PASS','manolis#1')
if strcmp(computer,'PCWIN64') && strcmp(getenv('UserName'),'Manolis') && false
    addpath(('Z:/libraries/mym_distribution'));mymSetup
    % setPathExt
    % addpath(getLocalPath('/lab/users\Manolis/Cajal/datajoint-matlab'))
    addpath_recurse(([getenv('HOMEDRIVE') getenv('HOMEPATH') '\Documents\github\datajoint-matlab']))
    % addpath_recurse(getLocalPath('/lab/users\Manolis/Cajal/pipeline/matlab/'))
    addpath_recurse(([getenv('HOMEDRIVE') getenv('HOMEPATH') '\Documents\github\pipeline\matlab']))
    addpath_recurse(([getenv('HOMEDRIVE') getenv('HOMEPATH') '\Documents\github\']))
    addpath_recurse(getLocalPath('/lab/users/Manolis/Matlab/Libraries'))

    % addpath_recurse(getLocalPath('/lab/users\Manolis/Cajal/commons'))
elseif strcmp(computer,'PCWIN64') 

    system_dependent('DirChangeHandleWarn', 'Never');
    warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning')
    warning('off','images:imfindcircles:warnForLargeRadiusRange')
    warning('off','images:imfindcircles:warnForSmallRadius')
    addpath ('Z:/users/Manolis/Matlab/Libraries')
    addpath Z:/users/Manolis/Matlab
    addpath_recurse ('Z:/users/Manolis/Matlab/Libraries')
    addpath_recurse('Z:/users/Manolis/Matlab/Datajoint2')
    addpath(('Z:/libraries/mym_distribution'));mymSetup
    addpath_recurse('Z:/users/Manolis/Matlab/working/datajoint-matlab/')
    addpath_recurse('Z:/users/Manolis/Matlab/working/pipeline/matlab')
    addpath_recurse('Z:/users/Manolis/Matlab/working/commons/')
    
    % new stuff
    %addpath_recurse('Z:/users/Manolis/Matlab/working/hdf5matlab/')
    addpath_recurse('Z:/users/Manolis/Matlab/working/visual-stimuli/')
    
    % testing
    addpath(genpath('Z:\users\Manolis\Matlab\working\ca_source_extraction'));
    addpath(genpath('Z:\users\Manolis\Matlab\working\oopsi'));
    run Z:\users\Manolis\Matlab\working\cvx\cvx_startup;
    run Z:\users\Manolis\Matlab\working\hdf5matlab\setPath;

elseif strcmp(computer,'MACI64')
    system_dependent('DirChangeHandleWarn', 'Never');
    warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning')
    warning('off','images:imfindcircles:warnForLargeRadiusRange')
    warning('off','images:imfindcircles:warnForSmallRadius')
    addpath ('/Volumes/lab/users/Manolis/Matlab/Libraries')
    addpath /Volumes/lab/users/Manolis/Matlab
    addpath_recurse ('/Volumes/lab/users/Manolis/Matlab/Libraries')
    addpath_recurse('/Volumes/lab/users/Manolis/Matlab/Datajoint2')
    addpath(('/Volumes/lab/libraries/mym_distribution'));mymSetup
    addpath_recurse('/Volumes/lab/users/Manolis/Matlab/working/datajoint-matlab/')
    addpath_recurse('/Volumes/lab/users/Manolis/Matlab/working/pipeline/matlab')
    addpath_recurse('/Volumes/lab/users/Manolis/Matlab/working/commons/')
    
    % new stuff
    addpath_recurse('/Volumes/lab/users/Manolis/Matlab/working/hdf5matlab/')
    addpath_recurse('/Volumes/lab/users/Manolis/Matlab/working/visual-stimuli/')
%     run ~/mym/mymSetu
%     run('/Volumes/lab/libraries/mym_distribution/mymSetup.m')
%     addpath('~/github/datajoint-matlab/')
%     addpath_recurse('~/github/pipeline/')
%     addpath_recurse('~/github/commons/')
%     addpath('~/github/PyMouse/matlab/')
elseif strcmp(computer,'GLNXA64')
    disp('Adding general files')
    addpath('/mnt/lab/users/Manolis/Matlab/working/datajoint-matlab')
    disp('Adding personal paths')
    addpath('/mnt/lab/users/Manolis/Matlab/Libraries')
    addpath_recurse('/mnt/lab/users/Manolis/Matlab/Libraries/')
    addpath('/mnt/lab/users/Manolis/Matlab/Datajoint2')

    disp('Adding pipeline code')
    addpath_recurse('/mnt/lab/users/Manolis/Matlab/working/pipeline/matlab/')
end


