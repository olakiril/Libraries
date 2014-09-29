function [stimfiles, tpTS] = syncStim2ScanImage(tpr,varargin)

% function syncStim2Tpr(tprname,varargin)
%
% Synchronizes the stimulation file with the AOD file
% writes the corrected Mac times into the stim file
%
% MF 2010-11-22

params.testingmode = 0;
params.manual = 1;
params =  getParams(params,varargin);

% load the tpfile related data
disp 'reading photodiode...'
pd = tpr.readPhotodiode';
params.nFrames = length(pd)/tpr.height;
pdSR = tpr.lps;

% get the stim files
[stimfiles, tpTS] = findStimFilesScanImage(tpr,params); 
pdSpF = mean(diff(tpTS))/(1000/pdSR);

% detect flip times
detflips = detectFlipsM(pd(:,1),pdSR,30);
flipTimes = interp1(tpTS, 1+(detflips/pdSpF),'linear','extrap'); % ms
flips = flipTimes;

idx = true(length(stimfiles),1);
for iStim = 1:length(stimfiles)
    
    try
    % Load the stim file
    stimData = load(getLocalPath(stimfiles{iStim}));
    
    % get the swapTimes for every trial
    swaps = vertcat(stimData.stim.params.trials.swapTimes)*1000; % ms
    catch
        idx(iStim) = false;
        continue
    end

    if ~params.manual

        % build stim vectors
        [vswaps, mdflips] = buildStimVector(swaps);
        vflips = buildStimVector(flips,mdflips);

        % organize..
        trace{1} = vswaps;
        trace{2} = vflips;
        [maxL, maxI] = max([length(vswaps) length(vflips)]);
        [minL, minI] = min([length(vswaps) length(vflips)]); %#ok<ASGLU>
        scor = [-1 1];
        
        % find the optimal shift
        cor = xcorr(trace{maxI},trace{minI});
        [amp, ind] = max(cor); %#ok<ASGLU>
        delay = ind - maxL;
        
        % correct the times
        timeCorrector =  flips(1) + delay*(scor(maxI)) - swaps(1);
    else
%         delay = alignVectors([flipTimes ones(length(flipTimes),1)],swaps +(tpTS(1) - swaps(1)),'marker','.');
%         
%         % correct the times
%         timeCorrector =  tpTS(1) + delay - swaps(1);
%         
         [delay, gain] = alignVectors([flipTimes ones(length(flipTimes),1)],swaps +(tpTS(1) - swaps(1)),'marker','.');
        % correct the times
        gainfix = @(x,gn)  (x-x(1))*(1 + gn/100) + x(1);
        timeCorrector = @(x) gainfix(x + delay,gain) + tpTS(1) - swaps(1);

    end

    if ~params.testingmode
        % save the corrected times in the stim file3
        disp('writing synced STIMtimestamps into file')
        for iTrial = 1:length(stimData.stim.events)
            oldTimes = stimData.stim.events(iTrial).times * 1000; %ms
            stimData.stim.events(iTrial).syncedTimes = timeCorrector(oldTimes);
        end
        stimData.stim.synchronized = 1;
        stim = stimData.stim; %#ok<NASGU>
        save(getLocalPath(stimfiles{iStim}),'stim')
    end
    swapsTest{iStim} = timeCorrector(swaps);  %#ok<AGROW>
end
stimfiles = stimfiles(idx);

figure
plot(flipTimes,ones(size(flipTimes)),'.');
hold on;
colors = hsv(length(stimfiles));
for iStim = 1:length(stimfiles)
    correctedSwaps =  swapsTest{iStim};
    plot(correctedSwaps,(iStim+1)*ones(size(correctedSwaps)),'.','Color',colors(iStim,:))
end
set(gca,'YLim',[0 100])
title(tpr.filepaths{1});

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