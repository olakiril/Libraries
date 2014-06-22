function stimfiles = syncStim2Tpr(tprname,varargin)

% function syncStim2Tpr(tprname,varargin)
%
% Synchronizes the stimulation file with the MpScan file
% writes the corrected Mac times into the stim file
%
% MF 2010-11-22

params.testingmode = 0;
params.manual = 0;
params =  getParams(params,varargin);

% get the stim files
[stimfiles, windows, macwindows] = findStimFiles(tprname,params);

% load the tpfile related data
tp = tpReader([tprname 'p%u.h5']);
tpTS = double(readTimestamps(tp));

pd = getElectrodeChannel(tp,1);
pdSR = getSamplingRate(pd);
pdSpF = double(getSamplesPerFrame(pd));

% detect flip times
detflips = detectFlipsM(pd(:,1),pdSR,30);
flipTimes = interp1(tpTS, 1+(detflips/pdSpF),'linear','extrap'); % ms

if params.manual
    % if no photodiode use Screen light contamination
%     im = tp.imCh{1}(:,:,:);
%     rd = normalize(squeeze(mean(mean(im,1),2)));
%     times = readTimestamps(tp);
%     marker = '-';
    % if photodiode
    rd = normalize(double(pd(1:pdSpF:end)));
    marker = '.';
end

for iStim = 1:length(stimfiles)

    % Load the stim file
    stimData = load(getLocalPath(stimfiles{iStim}));

    % get the swapTimes for every trial
    swaps = vertcat(stimData.stim.params.trials.swapTimes)*1000; % ms
    swapsL = swaps(end) - swaps(1);

    if ~params.manual
        % Chop Times
        flips = flipTimes(windows{iStim}(1)- 2*swapsL < flipTimes & ...
            windows{iStim}(2)+2*swapsL > flipTimes);
        flipsL = flips(end) - flips(1);
        swaps = swaps(macwindows{iStim}(1)*1000 - flipsL < swaps & ...
            macwindows{iStim}(2)*1000 + flipsL > swaps);

        % build stim vectors
        [vswaps, mdflips] = buildStimVector(swaps);
        vflips = buildStimVector(flips,mdflips);

        % organize..
        trace{1} = vswaps;
        trace{2} = vflips;
        [maxL, maxI] = max([length(vswaps) length(vflips)]);
        [minL, minI] = min([length(vswaps) length(vflips)]); %#ok<ASGLU>

        % find the optimal shift
        cor = xcorr(trace{maxI},trace{minI});
        [amp, ind] = max(cor); %#ok<ASGLU>
        delay = ind - maxL;
         if maxI == 1;delay = -delay;end
        % correct the times
        timeCorrector =  flips(1) + delay - swaps(1);
    else
        delay = alignVectors([flipTimes ones(length(flipTimes),1)],swaps +(tpTS(1) - swaps(1)),'marker',marker);
%         delay = alignData([times' rd],swaps +(tpTS(1) - swaps(1)),'marker',marker);
        % correct the times
        timeCorrector =  tpTS(1) + delay - swaps(1);

    end

    if ~params.testingmode
        % save the corrected times in the stim file3
        disp('writing synced STIMtimestamps into file')
        for iTrial = 1:length(stimData.stim.events)
            oldTimes = stimData.stim.events(iTrial).times * 1000; %ms
            stimData.stim.events(iTrial).syncedTimes = oldTimes + timeCorrector;
        end
        stimData.stim.synchronized = 1;
        stim = stimData.stim; %#ok<NASGU>
        save(getLocalPath(stimfiles{iStim}),'stim')
    end
    swapsTest{iStim} = swaps + timeCorrector;  %#ok<AGROW>
end

if ~params.testingmode && ~isempty(stimfiles)
    % write the times to the tp file
    disp('writing synced TPtimestamps into file')
    if isSynced( tp )
        tp = deleteSyncedTimestamps( tp );
    end
    if ~isSynced( tp )
        times = readTimestamps(tp);
        close(tp);
        try
            writeSyncedTimestamps( [tprname 'p%u.h5'], times, zeros(size(times)) );
        catch
            display('Could not write timestamps!')
        end
    end
    disp('Synchronization complete');
end

figure
plot(flipTimes,ones(size(flipTimes)),'.');
hold on;
colors = hsv(length(stimfiles));
for iStim = 1:length(stimfiles)
    correctedSwaps =  swapsTest{iStim};
    plot(correctedSwaps,(iStim+1)*ones(size(correctedSwaps)),'.','Color',colors(iStim,:))
end
set(gca,'YLim',[0 100])
title(tprname,'Interpreter','none');



% this function creates a time vector of 0s, and 1s where stimulus exists
function [stimVector, mdflips] = buildStimVector(stimTimes,mdflips)
cflips = round(stimTimes - stimTimes(1));
cflips(cflips == 0 ) = 1;
stimVector = ones(ceil(stimTimes(end) - stimTimes(1)),1);
dflips = diff(cflips);
if nargin<2
    mdflips = median(dflips);
end
indx = find(dflips > 2*mdflips);
for istop = 1:length(indx)
    stimVector(cflips(indx(istop)):cflips(indx(istop)+1)) = 0;
end