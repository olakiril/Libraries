function [times tmStamp] = readTpTimes(name,varargin)

% function times = readTpTimes(name)
%
% Coverts tp timestamps to seconds since 00:00 from _ts.mat file created by
% saveTpTimestamps.m and the original creation time of the file.
%
% MF 2010-11-05

params.precise = 1;
params.sync = 1;
params.timespace = 0;

params = getParams(params,varargin);
tpr  = tpReader([name 'p%u.h5']);
tmStamp = readTimestamps(tpr); % in milliseconds

if params.timespace && ~ isSynced(tpr)
    timestamp = load([name '_ts.mat']);
    times(1) = time2secs(timestamp.timestamp.Creation);
    
    key = fetch(Scans(['file_name = "' name(end-9:end) '"']));
    key.scan_idx = key.scan_idx+1;
    if ~isempty(Scans(key))
        name2 = fetch1(Scans(key),'file_name');
        timestamp2 = load([name(1:end-10) name2 '_ts.mat']);
        times(2) = time2secs(timestamp2.timestamp.Creation)-30;
    else
        times(2) = times(1) + (tmStamp(end)-tmStamp(1))/1000;
    end
else
    if isSynced(tpr) && params.sync;
        times = readSyncedTimestamps(tpr);
        close(tpr)
    else
        close(tpr)
        if params.precise
            dirname = fileparts(name);
            slfind = strfind(dirname,'\');
            dirname(slfind(slfind == 1)) = '';
            if length(dirname)>1;dirname(end+1) = '\';end;
            names = dir([dirname '*p0.h5']);
            realTimes = nan(length(names),1);
            otherTimes = nan(length(names),1);
            for ifile = 1:length(names)
                naming = names(ifile).name(1:end-5);
                tp = tpReader([dirname naming 'p%u.h5']);
                t = readTimestamps(tp);
                close(tp)
                realTimes(ifile) = t(1)/1000;
                timestamp = load([dirname naming '_ts.mat']);
                secs = time2secs(timestamp.timestamp.Creation);
                otherTimes(ifile) = secs;
            end
            
            reg = regress(otherTimes,[ones(size(realTimes)) realTimes])';
            times = (reg(1) + reg(2)*tmStamp/1000);
        else
            
            timestamp = load([name '_ts.mat']);
            secs = time2secs(timestamp.timestamp.Creation);
            rawtimes = tmStamp - tmStamp(1); % relative time to start
            times = rawtimes/1000 + secs; % add offset since 00:00 in seconds
        end
    end
end
function secs = time2secs(timename)
starthour = timename(4);
startmin = timename(5);
startsec = timename(6);
secs = starthour*3600 + startmin*60 + startsec;


