function p = getLocalPath(p,os)
% Converts path names to local operating system format using lab conventions.
%
%    localPath = getLocalPath(inputPath) converts inputPath to local OS format 
%    using lab conventions. The following paths are converted:
%   
%       input       Linux            Windows      Mac
%       /lab        /mnt/lab         Z:\          /Volumes/lab
%       /stor01     /mnt/stor01      Y:\          /Volumes/stor01
%       /stor02     /mnt/stor02      X:\          /Volumes/stor02
%       /scratch01  /mnt/scratch01   V:\          /Volumes/scratch01
%       /2P1        /mnt/2P1         M:\          /Volumes/2P1
%
%    localPath = getLocalPath(inputPath,OS) will return the path in the format
%    of the operating system specified in OS ('linux' |'win' | 'mac')
%
% AE 2007-09-26
% MF 2011-09-26 Added /scratch01
% MF 2013-08-12 Added /2P1

% determine operating system;
if nargin < 2
    os = computer;
end
os = os(1:min(3,length(os)));

% local aliases
input = {'/lab','/stor01','/stor02','/scratch01','/2P1'};
switch lower(os)
    case {'win','pcw'}
        local = {'Z:','Y:','X:','V:','M:'};
    case {'lin','gln'}
        local = {'/mnt/lab','/mnt/stor01','/mnt/stor02','/mnt/scratch01','/mnt/2P1'};
    case 'mac'
        local = {'/Volumes/lab','/Volumes/stor01','/Volumes/stor02','/Volumes/scratch01','/Volumes/2P1'};
end

% convert path
for i = 1:length(input)
    n = length(input{i});
    if strncmp(p,input{i},n)
        p = [local{i}, p(n+1:end)];
        break;
    end
end

% make sure there are no backslashes
 p(strfind(p,'\')) = '/';