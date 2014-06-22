function [times tmStamp] = readImagerTimes(filename)

% function times = readImagerTimes(name)
%
% Coverts tp timestamps to seconds since 00:00 from txt file created by
% h5timestamps and the original timestamp of the file.
%
% MF 2011-03-09

[path name] = fileparts(filename);
[trace fs] = getOpticalData([path '/' name '.h5'],1); % get photodiode data

tmStamp = 0:1/fs:size(trace)/fs-1/fs; % compute timestamps in sec

% write the filename
fid = fopen('Z:\users\Manolis\Labview\Sync\Builts\file.txt', 'w');
fprintf(fid, '%s', [path '/' name '.h5']);
fclose(fid);
fid = fopen('Z:\users\Manolis\Labview\Sync\Builts\channel.txt', 'w');
fprintf(fid, '%s', ['ephys' ';' 'photodiode']); % Parent;Channel
fclose(fid);

!Z:\users\Manolis\Labview\Sync\Builts\h5timestamp.exe

% Read the data
fid = fopen([filename(1:end-2) 'txt']);
secs = str2double(fscanf(fid, '%s'));
fclose(fid);

rawtimes = tmStamp- tmStamp(1); % relative time to start 
times = rawtimes + secs; % add offset since 00:00 in seconds



