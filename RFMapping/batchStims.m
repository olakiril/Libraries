function batchStims(filename)

if strcmp(filename(end-9:end),'101102_008')
    stimFilename = '/stor01/stimulation/Mouse2P1/2010-11-02_17-42-13/DotMappingExperiment.mat';
else
    stimFilename = findStimFileManual ( filename );
end

if isempty(stimFilename)
    display([filename ' is not correlated with any stimulation file, skipping...'])
    return
end

% fixStim(stimFilename);

% load the stimulation file
load(getLocalPath(stimFilename));

if ~stim.synchronized
    for iTrial = 1:length(stim.params.trials)
        
        startIndx = find(strcmp(vertcat(stim.eventTypes),'showStimulus'));
        oldTime = stim.events(iTrial).times(startIndx == stim.events(iTrial).types);
        newTime = stim.params.trials(iTrial).dotTimes(1);
        timeCorr = newTime - oldTime;
        oldTimes = stim.events(iTrial).times;
        stim.evens(iTrial).syncedTimes = (oldTimes + timeCorr)*1000; %ms
    end
    stim.synchronized = 1;
    save(getLocalPath(stimFilename),'stim')
else
    display('file already synched')
end

