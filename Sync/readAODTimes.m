function [times tmStamp] = readAODTimes(name,varargin)

% function times = readAODTimes(name)
%
% Coverts tp timestamps to seconds since 00:00 from txt file created by
% h5timestamps and the original timestamp of the file.
%
% MF 2011-03-09

params.fps = 40;
params.aodReader = 'old';

params = getParams( params, varargin);

if strcmp(params.aodReader,'new')
    [~,tmStamp] = loadAODTraces(name,params.fps);
    hr = str2double(name(end - 13:end - 12)) * 3600;
    mn = str2double(name(end - 10:end - 9)) * 60;
    sc = str2double(name(end - 7:end - 6));
    secs = hr + mn + sc;
else
    [~,tmStamp] = loadTraces(name,params.fps);
        % write the filename
    fid = fopen('Z:\users\Manolis\Labview\Sync\Builts\file.txt', 'w');
    fprintf(fid, '%s', name);
    fclose(fid);
    fid = fopen('Z:\users\Manolis\Labview\Sync\Builts\channel.txt', 'w');
    fprintf(fid, '%s', ['ImData' ';' 'ImCh1']); % Parent;Channel
    fclose(fid);

    !Z:\users\Manolis\Labview\Sync\Builts\h5timestamp.exe

    % Read the data
    fid = fopen([name(1:end - 2) 'txt']);
    secs = str2double(fscanf(fid, '%s'));
    fclose(fid);
end



rawtimes = tmStamp - tmStamp(1); % relative time to start
times = rawtimes + secs; % add offset since 00:00 in seconds



