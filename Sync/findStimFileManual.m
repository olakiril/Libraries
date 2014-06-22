function stimFilenames = findStimFileManual ( name, varargin )

% function stimFilename = findStimFileManual( MPScanfilename, varargin )
%
% Finds the directory *.mat file with stimulus information with overlapping
% time stamps to those in the tpr.
%
% MF: 2010-10-05

params.stimBasePath = '/stor01/stimulation/Mouse2P1';

params = parseVarArgs( params, varargin{:});

% use the filename to infer the scan date
params.date = datestr( datenum(  name(end-9:end-4), 'yymmdd'), 'yyyy-mm-dd');

scanDay = datenum( params.date );
params.stimBasePath = getLocalPath(params.stimBasePath);

% get real time (seconds since last 00:00)
timestamps = readTpTimes( name ,'sync',0);

stimFilenames = [];
stims = 0;

for iDay = -1:1    %also check one day before and after
    
    day = scanDay + iDay; 
    stimDirPattern = datestr( day, 'yyyy-mm-dd*' );
    stimDirs = dir(fullfile(params.stimBasePath, stimDirPattern));

    for iDir=1:length(stimDirs)

        stimDir = fullfile(params.stimBasePath, stimDirs(iDir).name);
        stimFiles = dir(fullfile(stimDir, '*.mat'));

        for iFile=1:length(stimFiles)

            filename = fullfile(stimDir, stimFiles(iFile).name);

            if exist(filename, 'file') && ~strcmp( filename(end-10:end), 'Synched.mat' )

                % Load the file and check the timestamps
                stimData = load(filename);

                if isfield(stimData,'stim') && ~isempty(stimData.stim.params.trials)

                    % get mac times
                    macTStamps = vertcat(stimData.stim.params.trials.swapTimes) ;

                    % loop for 12hour mistake
                    for t = 0:1
                        % convert to real time (seconds since last 00:00)
                        hours2sec = 3600 * (str2double(stimDir(end-7:end-6))+ t*12 + iDay*24);
                        min2sec = 60 * str2double(stimDir(end-4:end-3));
                        sec = str2double(stimDir(end-1:end));
                        timeCorrector = hours2sec + min2sec + sec - min(macTStamps);
                        macStamps = macTStamps + timeCorrector ;

                        % select if there is any kind of overlap
                        rangeStamps = [min(timestamps) max(timestamps)];
                        overlaps = macStamps >= rangeStamps(1) & macStamps <= rangeStamps(2);
                        overlapLength = sum(overlaps);

                        if overlapLength
                            stims = stims + 1;
                            stimFilenames{stims} = getGlobalPath( filename ); %#ok<AGROW>
                            overlaplengths(stims) = overlapLength; %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
end

display (['Found ' num2str(stims) ' stimulation files']);
[maxL maxi] = max(overlaplengths); %#ok<ASGLU>
stimFilenames = stimFilenames{maxi};
if ~isempty( stimFilenames )

        fprintf('Found matching stim file %s\n', stimFilenames );

end


