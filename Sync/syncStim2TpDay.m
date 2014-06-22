function syncStim2TpDay(exp_date,varargin)

params.stimPath = '/stor01/stimulation/Mouse2P1';
params.scan_prog = 'MPScan';
params.stim_engine = 'State';
params.length_thr = 30; % stimulus length threshold in seconds
params.testingmode = 0;

params = getParams( params, varargin);

key.exp_date = exp_date;
key.scan_prog = params.scan_prog;
key.stim_engine = params.stim_engine;

% get all photodiode flip times
keys = fetch(Scans(key,'problem_type = "none!"'));

flipTimes = cell(length(keys),1);
ikeys = 1:length(keys);
for ikey = 1:length(keys)
    
    tp = tpReader(Scans(keys(ikeys(ikey))));
    tpTS = double(readTimestamps(tp));
    try
    pd = getElectrodeChannel(tp,1);
    catch
       display(['No photodiode signal, skipping ' keys(ikeys(ikey)).exp_date]) 
       keys(ikeys(ikey)) = [];
       flipTimes(end) = [];
       ikeys = ikeys - 1;
       continue
    end
    pdSR = getSamplingRate(pd);
    pdSpF = double(getSamplesPerFrame(pd));
    
    % detect flip times
    detflips = detectFlipsM(pd(:,1),pdSR,30);
    flipTimes{ikeys(ikey)} = interp1(tpTS, 1+(detflips/pdSpF),'linear','extrap'); % ms
    close(tp);
end

flips = sort(cell2mat(flipTimes));

% get all stimuli swap times
stimPath = getLocalPath(params.stimPath);
stimDirPattern = datestr(  datenum( key.exp_date ), 'yyyy-mm-dd*' );
stimDirs = dir(fullfile(stimPath, stimDirPattern));

swapTimes = cell(length(stimDirs),1);
dind = false(length(stimDirs),1);
for iDir=1:length(stimDirs)
    
    stimDir = fullfile(stimPath, stimDirs(iDir).name);
    stimFiles = dir(fullfile(stimDir, '*.mat'));
    indx = true(length(stimFiles),1);
    for iFile = 1:length(stimFiles)
        if ~isempty(strfind(stimFiles(iFile).name,'Synched'))
            indx(iFile) = false;
        end
    end
    stimFiles = stimFiles(indx);
    if length(stimFiles)>1;
       display(['Too many stimulation files in ' stimDir ' skipping..'])
       continue
    end
    
    filename = fullfile(stimDir, stimFiles(1).name);
    % Load the file and check the timestamps
    stimData = load(filename);
    if isfield(stimData,'stim') && ~isempty(stimData.stim.params.trials)
        % get mac times
        swapTimes{iDir} = vertcat(stimData.stim.params.trials.swapTimes) ;
        dind(iDir) = true;
    end
end
swapTimes = swapTimes(dind);
stimDirs = stimDirs(dind);

swaps = cell2mat(swapTimes)*1000; %ms

% build stim vectors
[trace{1}, mdflips] = buildStimVector(swaps);
trace{2} = buildStimVector(flips,mdflips);

% organize..
[maxL, maxI] = max([length(trace{1}) length(trace{2})]);
[minL, minI] = min([length(trace{1}) length(trace{2})]); %#ok<ASGLU>

% find the optimal shift
cor = xcorr(double(trace{maxI}),double(trace{minI}));
[foo,ind] = max(cor);
delay = ind - maxL;

if maxI == 1;delay = -delay;end

timeCorrector =  flips(1) + delay - swaps(1);
swapsC = swaps + timeCorrector;

figure
plot(flips,ones(size(flips)),'.');
hold on;
plot(swapsC,ones(size(swapsC))+1,'.r')
set(gca,'YLim',[0 100])

swapTimes = cellfun(@(x) x*1000,swapTimes,'uniformoutput',0);

% get rid of synced keys
for ikey = 1:length(keys)
    
    flips = flipTimes{ikey};
    
    eSwaps = cell2mat(cellfun(@(x) [x(1) x(end)]+timeCorrector,swapTimes,'uniformoutput',0));
    
    indx = (flips(1)<=eSwaps(:,1) & flips(end)>=eSwaps(:,1)) |...
        (flips(1)<=eSwaps(:,2) & flips(end)>=eSwaps(:,2)) |...
        (flips(1)>=eSwaps(:,1) & flips(end)<=eSwaps(:,2));
    indx = find(eSwaps(:,2) - eSwaps(:,1) > params.length_thr*1000 & indx);
    
    swapsC = cell(length(indx),1);
    snames = cell(length(swapsC)+1,1);
    snames{1} = ['scanFile: ' fetch1(Scans(keys(ikey)),'file_name')];
    for iStim = 1:length(indx)
        
        swaps = swapTimes{indx(iStim)};
        
        % build stim vectors
        [trace{1}, mdflips] = buildStimVector(swaps);
        trace{2} = buildStimVector(flips,mdflips);
        
        % organize..
        [maxL, maxI] = max([length(trace{1}) length(trace{2})]);
        [minL, minI] = min([length(trace{1}) length(trace{2})]); %#ok<ASGLU>
        
        % find the optimal shift
        cor = xcorr(double(trace{maxI}),double(trace{minI}));
        [foo,ind] = max(cor);
        delay = ind - maxL;
        
        if maxI == 1;delay = -delay;end
        timeCorrector =  flips(1) + delay - swaps(1);
        swapsC{iStim} = swaps + timeCorrector;
        stimDir = fullfile(stimPath, stimDirs(indx(iStim)).name);
        stimFiles = dir(fullfile(stimDir, '*.mat'));
        filename = fullfile(stimDir, stimFiles(1).name);
        stimData = load(filename);
        
        if ~params.testingmode
            % save the corrected times in the stim file3
            disp('writing synced STIMtimestamps into file')
            for iTrial = 1:length(stimData.stim.events)
                oldTimes = stimData.stim.events(iTrial).times * 1000; %ms
                stimData.stim.events(iTrial).syncedTimes = oldTimes + timeCorrector;
            end
            stimData.stim.synchronized = 1;
            stim = stimData.stim; %#ok<NASGU>
            save(getLocalPath(filename),'stim')
        end
        snames{iStim+1} = ['stimFile: ' stimData.stim.date];
    end
    
    if ~params.testingmode && ~isempty(indx)
        % write the times to the tp file
        tp = tpReader(Scans(keys(ikey)));
        if isSynced( tp )
            tp = deleteSyncedTimestamps( tp );
        end
        if ~isSynced( tp )
            disp('writing synced TPtimestamps into file')
            times = readTimestamps(tp);
            tprname =  getFilename(tp);
            close(tp);
            try
                 writeSyncedTimestamps(tprname, times, zeros(size(times)) );
            catch
                display('tp error')
            end
        end
        disp(['Synchronizing ' tprname ' complete']);
    end
    
    figure
    plot(flips,ones(size(flips)),'.');
    hold on;
    colors = hsv(length(swapsC));
    
    
    for iStim = 1:length(swapsC)
        correctedSwaps =  swapsC{iStim};
        plot(correctedSwaps,(iStim+1)*ones(size(correctedSwaps)),'.','Color',colors(iStim,:))
    end
    set(gca,'YLim',[0 100])
    l = legend(snames);
    legend('boxoff')
    set(l,'Location','northwest','Interpreter','none')
    title([keys(ikey).exp_date ' scan:' num2str(keys(ikey).scan_idx)] ,'Interpreter','none');
end

% this function creates a time vector of 0s, and 1s where stimulus exists
function [stimVector, mdflips] = buildStimVector(stimTimes,mdflips)
cflips = round(stimTimes - stimTimes(1));
cflips(cflips == 0 ) = 1;
stimVector = single(ones(ceil(stimTimes(end) - stimTimes(1)),1));
dflips = diff(cflips);
if nargin<2
    mdflips = median(dflips);
end
indx = find(dflips > 2*mdflips);
for istop = 1:length(indx)
    stimVector(cflips(indx(istop)):cflips(indx(istop)+1)) = single(0);
end


