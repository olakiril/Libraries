function [stimFilename window macwindow oldTS] = findStimFiles ( name, varargin )

% function [stimFilename window] = findStimFileManual( MPScanfilename, varargin )
%
% Finds the directory *.mat file with stimulus information with overlapping
% time stamps to those in the tpr.
% Spits out also the first and the last MpScan times that the correlation
% exists, window = [first last];
%
%%%% WARNING!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function assumes that the real time difference between mac and
% windows computer is significantly smaller than the length of the stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MF: 2010-10-05

params.stimPath = '/stor01/stimulation/Mouse2P1';
params.supressOutput = 0;
params.minLength = 90; % minimum length in s
params.timespace = 1;
params.scprog = 'MPScan';
params.aodReader = 'old';
params.filename = [];

params = getParams( params, varargin);

if strcmp(params.scprog,'MPScan')
    tp = tpReader([name 'p%u.h5']);
    isSync = isSynced(tp);
    if ~strcmp(params.stimPath,'/stor01/stimulation/Mouse2P1') && ~strcmp(params.stimPath,'/stor01/stimulation/Mouse')
        stimFilename{1} = findStimFile(tp);
        close(tp)
        return
    end
    % use the filename to infer the scan date
    params.date = datestr( datenum(  name(end-9:end-4), 'yymmdd'), 'yyyy-mm-dd');
    
    % get real time (seconds since last 00:00)
    [timestamps, oldTS] = readTpTimes( name ,params );
elseif strcmp(params.scprog,'AOD')
    % use the filename to infer the scan date
    if ~isfield(params,'date')
        params.date = datestr( datenum(  name(1:6), 'yymmdd'), 'yyyy-mm-dd');
    end
    % get real time (seconds since last 00:00)
    [timestamps, oldTS] = readAODTimes(name,params);
    isSync = 0;
elseif strcmp(params.scprog,'Unirec')
    % use the filename to infer the scan date
    [foo,fname] = fileparts(name);
    if ~isfield(params,'date')
        params.date = datestr( datenum(  fname(1:8), 'yy-mm-dd'), 'yyyy-mm-dd');
    end
    % get real time (seconds since last 00:00)
    [timestamps, oldTS] = readUnirecTimes( name);
    isSync = 0;
elseif strcmp(params.scprog,'Imager')
    % use the filename to infer the scan date
    [foo,fname] = fileparts(name);
    if ~isfield(params,'date')
        params.date = datestr( datenum(  fname(1:8), 'yy-mm-dd'), 'yyyy-mm-dd');
    end
    % get real time (seconds since last 00:00)
    [timestamps, oldTS] = readImagerTimes( name);
    isSync = 0;

end

scanDay = datenum( params.date );
stimPath = getLocalPath(params.stimPath);
stimFilename= {};
window = {};
macwindow = {};
stims = 0;

for iDay =0%:1    %also check one day after
    
    day = scanDay + iDay;
    stimDirPattern = datestr( day, 'yyyy-mm-dd*' );
    stimDirs = dir(fullfile(stimPath, stimDirPattern));
    
    for iDir=1:length(stimDirs)
        
        stimDir = fullfile(stimPath, stimDirs(iDir).name);
        stimFiles = dir(fullfile(stimDir, '*.mat'));
        
        for iFile=1:length(stimFiles)
            
            filename = fullfile(stimDir, stimFiles(iFile).name);
            
            if exist(filename, 'file') && ~strcmp( filename(end-10:end), 'Synched.mat' )
                
                % Load the file and check the timestamps
                stimData = load(filename);
                
                if isfield(stimData,'stim') && ~isempty(stimData.stim.params.trials)
   
                    % get mac times
                    macTStamps = vertcat(stimData.stim.params.trials.swapTimes) ;
                    
                    if stimData.stim.synchronized== 1 && isSync 
                        
                        startIndx = find(strcmp(vertcat(stimData.stim.eventTypes),'showStimulus'));
                        endIndx = find(strcmp(vertcat(stimData.stim.eventTypes),'endStimulus'));
                        syncedTimes = horzcat(stimData.stim.events.syncedTimes);
                        macStamps = syncedTimes(startIndx == horzcat(stimData.stim.events.types) | endIndx == horzcat(stimData.stim.events.types));
                        
                    else
                        % convert to real time (seconds since last 00:00)
                        hours2sec = 3600 * (str2double(stimDir(end-7:end-6)) + iDay*24);
                        min2sec = 60 * str2double(stimDir(end-4:end-3));
                        sec = str2double(stimDir(end-1:end));
                        timeCorrector = hours2sec + min2sec + sec - min(macTStamps);
                        macStamps = macTStamps + timeCorrector ;
                    end
                    
                    % select if there is any kind of overlap
                    overlaps = macStamps >= timestamps(1) & macStamps <= timestamps(end);
                    overlapLength = sum(overlaps);
%                     disp([num2str(iDay) ' ' num2str(iDir) ' ' stimDirs(iDir).name...
%                         ' ' num2str(iFile) ' ' num2str(overlapLength)])
                    if strcmp(params.filename,getGlobalPath( filename )) || overlapLength && macTStamps(end) - macTStamps(1) > params.minLength
                        stims = stims + 1;
                        stimFilename{stims} = getGlobalPath( filename ); %#ok<AGROW>
                        [foo, minI] = min(abs(timestamps - macStamps(1))); 
                        [foo, maxI] = min(abs(timestamps - macStamps(end))); 
                        window{stims} = [oldTS(minI) oldTS(maxI)]; %#ok<AGROW>
                        [foo, minI] = min(abs(macStamps - timestamps(1))); 
                        [foo, maxI] = min(abs(macStamps - timestamps(end))); 
                        macwindow{stims} = [macTStamps(minI) macTStamps(maxI)]; %#ok<AGROW>
                    end
                end
            end
        end
    end
end

if ~params.supressOutput
    display (['Found ' num2str(stims) ' stimulation files for file ' name]);
    
    for iStim = stimFilename
        fprintf('Found matching stim file %s\n', iStim{1} );
    end
end


