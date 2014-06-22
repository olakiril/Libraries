function out = gladCmp(dirName,targetName,varargin)

% Compares files in different locations & copies

% Copy files
copycommand = 0;
if ~isempty(varargin)
    copycommand = varargin{1};
end

%Initialize
out = {};
base = '';

% fild all directories
allDirs = genpath(fullfile(base,dirName));
dirs = strfind(allDirs,';');
dirs = [0 dirs];
corDir = cell(length(dirs)-1,1);
for i = 2:length(dirs)
    corDir{i-1} = allDirs(dirs(i-1)+1:dirs(i)-1);
end

for i = 1:length(corDir) % loop through all directories
    list = dir(fullfile(base,corDir{i}));
    list = list(~[list.isdir]);
    for y = 1:length(list) % loop through all files in each directory
        nameC = list(y).name;
        check = exist(fullfile(targetName,corDir{i}(length(corDir{1})+1:end),nameC),'file');
        if ~check && ~strcmp(nameC(end-2:end),'.db') && ~strcmp(nameC(end-2:end),'ini') 
            out{end+1} = fullfile(corDir{i},list(y).name); %#ok<AGROW>
        end
    end
end

% display results
char(out)

if copycommand
    % make sure all directories exist
    for i = 1:length(corDir)
        check = exist(fullfile(targetName,corDir{i}(length(corDir{1})+1:end)),'dir');
        if ~check
            mkdir(fullfile(targetName,corDir{i}(length(corDir{1})+1:end)));
        end
    end
    
    % copy files
    for i = 1:length(out)
        display (['Copying: ' num2str(out{i})]);
        s = copyfile(out{i},[targetName(1:end-length(dirName))  out{i}]);
        if s
            display('Success!!!')
        else
            display('FAIL')
        end
    end
end