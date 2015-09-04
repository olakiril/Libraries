function [stimFilename, tstamps] = findStimFilesScanImage ( tpr, varargin )

% function [stimFilename tstamps] = findStimFileScanImage( key, varargin )
%
% Finds the directory *.mat file with stimulus information with overlapping
% time stamps to those in the scanimage file.
%
% MF: 2013-09

params.stimPath = '/stor01';
params.supressOutput = 0;
params.minLength = 20; % minimum length in s

params = getParams( params, varargin);

% get times 
tstamps = tpr.readTimes(params.nFrames);

% add some window of opportunity
sStart = num2str(tstamps(1) - 10000);
sEnd = num2str(tstamps(end));

[stimFiles, expType] = ...
    fetchn(vis2p.Stimulation(['stim_start_time>' sStart ' and stim_start_time<' sEnd]),...
    'stim_path','exp_type');

stimFilename = cell(length(stimFiles),1);
for iFile=1:length(stimFiles)
    if strcmp(expType{iFile},'MouseMultiDim');name = 'MultDimExperiment';
    elseif strcmp(expType{iFile},'NatImExperimentMouse');name = 'NatImExperiment';
    else name = expType{iFile}; end
    stimFilename{iFile} = [params.stimPath stimFiles{iFile} '/' name '.mat'];
end    

if ~params.supressOutput
    display (['Found ' num2str(length(stimFiles)) ' stimulation files for file ' tpr.filepaths{1}]);
    
    for iStim = stimFilename
        fprintf('Found matching stim file %s\n', iStim{1} );
    end
end


