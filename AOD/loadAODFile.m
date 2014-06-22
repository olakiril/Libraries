function [dat path] = loadAODFile(fn,raw)

if nargin < 2; raw = false; end

try
    info = hdf5info(fn);
catch
    try
        info = hdf5info(fn);
    catch
        info = hdf5info(fn);
    end
end

if length(info.GroupHierarchy.Groups(1).Groups(1).Groups) == 6
    dat{1} = hdf5read(fn,'/wfm_group0/axes/axis1/data_vector/data');
    dat{2} = hdf5read(fn,'/wfm_group0/axes/axis3/data_vector/data');
    dat{3} = hdf5read(fn,'/wfm_group0/axes/axis5/data_vector/data');
    path = '/wfm_group0/axes/axis1/data_vector/data';
elseif length(info.GroupHierarchy.Groups(2).Groups(1).Groups) == 6
    dat{1} = hdf5read(fn,'/wfm_group1/axes/axis1/data_vector/data');
    dat{2} = hdf5read(fn,'/wfm_group1/axes/axis3/data_vector/data');
    dat{3} = hdf5read(fn,'/wfm_group1/axes/axis5/data_vector/data');
    path = '/wfm_group1/axes/axis1/data_vector/data';
elseif length(info.GroupHierarchy.Groups) > 2
    % latest format
    path = '';
    dat{1} = hdf5read(fn,'/wfm_group2/axes/axis1/data_vector/data');
    
    %if dat{1}(1) == 0  % deal with bug where points not written to the right group
    %    dat{2} = hdf5read(fn,'/wfm_group3/axes/axis1/data_vector/data');  % load coordinates/scan settings
    %elseif dat{1}(1) == 1 % deal with bug where 
        dat{2} = hdf5read(fn,'/wfm_group2/axes/axis3/data_vector/data');  % load coordinates/scan settings
    %end
    
    dat{3} = hdf5read(fn,'/wfm_group1/axes/axis1/data_vector/data');  % main data
    if length(info.GroupHierarchy.Groups(2).Groups(1).Groups) > 2
        dat{4} = hdf5read(fn,'/wfm_group1/axes/axis3/data_vector/data');  % second channel
    elseif length(info.GroupHierarchy.Groups(2).Groups(1).Groups) > 4
        dat{5} = hdf5read(fn,'/wfm_group1/axes/axis5/data_vector/data');  % third channel
    elseif length(info.GroupHierarchy.Groups(2).Groups(1).Groups) > 6
        dat{6} = hdf5read(fn,'/wfm_group1/axes/axis7/data_vector/data');  % third channel
    end

    if raw && length(info.GroupHierarchy.Groups(2).Groups(1).Groups) > 1 
        dat{end+1} = hdf5read(fn,'/wfm_group0/axes/axis1/data_vector/data');  % third channel
    end               
        
%    dat{4} = hdf5read(fn,'/wfm_group0/axes/axis1/data_vector/data');  % main data
end
