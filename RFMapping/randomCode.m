dirName = 'Y:\stimulation\Mouse2P1';
dirnames = dir([dirName '\2010-11-0*']);
%%
for iDir = 1:length(dirnames)
    stimdir = [dirName '\' dirnames(iDir).name];
    stims = dir([stimdir '\*.mat']);
    if ~isempty(stims)
        filename = ([stimdir '\' stims.name]);
        load (filename);
        if sum(strcmp(fieldnames(stim.params.trials),'dotTimes'))>0
            for iTrial = 1:length(stim.params.trials)
                startIndx = find(strcmp(vertcat(stim.eventTypes),'showStimulus'));
                oldTime = stim.events(iTrial).times(startIndx == stim.events(iTrial).types);
                newTime = stim.params.trials(iTrial).dotTimes(1);
                timeCorr = newTime - oldTime;
                oldTimes = stim.events(iTrial).times;
                stim.events(iTrial).syncedTimes = (oldTimes + timeCorr); %ms
            end
            save(filename,'stim')
        end
    end
end
%%

names = dir('*p0.h5');
%%
for ifile = 7:length(names)
    [newtimes oldtimes] = readTpTimes(names(ifile).name(1:end-5));
    truetimes = newtimes + oldtimes(1);
    tpr  = tpReader([names(ifile).name(1:end-5) 'p%u.h5']);
    if isSynced( tpr )
        tpr = deleteSyncedTimestamps( tpr );
        display(['deleting...' num2str(ifile)])
    end
    if ~isSynced( tpr )
        tpr = writeSyncedTimestamps( tpr, truetimes ,zeros(size(truetimes)) );
        display(['writting...' num2str(ifile)])
    end
    
    stimfilename = getLocalPath(findStimFileManual(names(ifile).name(1:end-5)));
    load(stimfilename)
    for iTrial = 1:length(stim.params.trials)    
        stim.events(iTrial).syncedTimes = stim.events(iTrial).syncedTimes + oldtimes(1);
    end
    save(stimfilename,'stim')
end