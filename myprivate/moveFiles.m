function moveFiles(from,folderType,to,type,varargin)

% function moveFiles(baseDir,from,to,type,varargin)
%
% moves files to specified directory
% from : base Directory
% folderType: type of folders that are copied (e.g. 0810* will copy october
%             2008 folders
% to: directory where everything will be copied
% type: type of files to be copied
%
% params.cut: deletes the files afterwards
%
% MF 2009-09-21

params.cut = 0;

for i=1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

% get all folders that match folderType
copyDir = dir([from folderType]);
if isempty(copyDir)
    display('base folder is empty')
end

% loop through folders
for dirIndx = 1:length(copyDir)
    % get all files in the folder that match the type
    copyFiles = dir([from copyDir(dirIndx).name '/' type]);
    if isempty(copyFiles)
        display([copyDir(dirIndx).name ' folder is empty'])
        continue
    end
    
    % create copying directory 
    mkdir([to '/' copyDir(dirIndx).name ]);
    
    %loop through files
    for fileIndx = 1:length(copyFiles)
        display(['Copying file  ' copyFiles(fileIndx).name])
        [s,mess,messid] = copyfile([from copyDir(dirIndx).name '/'...
            copyFiles(fileIndx).name],[to copyDir(dirIndx).name '/'...
            copyFiles(fileIndx).name] );
        display(['Copying file  ' copyFiles(fileIndx).name '  finished']);
        
        % in error don't delete
        if ~s
            display(mess)
            display(messid)
            continue
        end
        
        % delete files
        if params.cut
            delete([from copyDir(dirIndx).name '/' copyFiles(fileIndx).name]);
            display(['file  ' copyFiles(fileIndx).name '  deleted']);
        end
    end
end
