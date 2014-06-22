function [stimfiles tpTS] = syncStim2Unirec(tprname,varargin)

% function syncStim2Tpr(tprname,varargin)
%
% Synchronizes the stimulation file with the AOD file
% writes the corrected Mac times into the stim file
%
% MF 2010-11-22

params.testingmode = 0;
params =  getParams(params,varargin);
gainfix = @(x,gn,x1,xend)  (x-x1)*(1 + gn/(xend - x1)) + x1;

% get the stim files
[stimfiles windows macwindows tpTS] = findStimFiles(tprname,params); %#ok<ASGLU>

% load the tpfile related data
tpTS = tpTS*1000; % convert to ms
 [path,name] = fileparts(tprname);
br = baseReader([path '/' name '%d.h5']);
pd = br(:,find(strcmp(getChannelNames(br),'pd'))); %#ok<FNDSB>
pdSR = getSamplingRate(br);

% detect flip times
detflips = detectFlipsM(pd(:,1),pdSR,30);
% flipTimes = interp1(tpTS, 1+(detflips/pdSpF),'linear','extrap'); % ms
flipTimes = detflips/pdSR*1000;

for iStim = 1:length(stimfiles)
    
    % Load the stim file
    stimData = load(getLocalPath(stimfiles{iStim}));
    
    % get the swapTimes for every trial
    swaps = vertcat(stimData.stim.params.trials.swapTimes)*1000; % ms
%     swapsL = swaps(end) - swaps(1);
    
    flips = flipTimes;
    
    gains = -200:1:200; % range of gains in ms
    amp = nan(length(gains),1); ind = amp;
    for igain = 1:length(gains);
        
        % build stim vectors
        [vswaps mdflips] = buildStimVector(gainfix(swaps,gains(igain),swaps(1),swaps(end)));
        vflips = buildStimVector(flips,mdflips);
        
        % organize..
        trace{1} = vswaps;
        trace{2} = vflips;
        [maxL maxI] = max([length(vswaps) length(vflips)]);
        [minL minI] = min([length(vswaps) length(vflips)]); %#ok<ASGLU>
        
        % find the optimal shift
        cor = xcorr(trace{maxI},trace{minI});
        [amp(igain), ind(igain)] = max(cor);
    end
    [~,cor] = max(amp);
     
    % correct the times
    timeCorrector = @(x) gainfix(x,gains(cor),swaps(1),swaps(end)) + ...
        flips(1) + ind(cor) - maxL - swaps(1);
    
    if ~params.testingmode
        % save the corrected times in the stim file3
        disp('writing synced STIM timestamps into file')
        for iTrial = 1:length(stimData.stim.events)
            oldTimes = stimData.stim.events(iTrial).times * 1000; %ms
            stimData.stim.events(iTrial).syncedTimes = timeCorrector(oldTimes);
        end
        stimData.stim.synchronized = 1;
        stim = stimData.stim; %#ok<NASGU>
        save(getLocalPath(stimfiles{iStim}),'stim')
         swapsTest{iStim} = timeCorrector(swaps);%#ok<AGROW>
    else
        swapsTest{iStim} = timeCorrector(swaps);%#ok<AGROW>
    end
end

% if params.testingmode
    % testing mode
    figure
    plot(flipTimes,ones(size(flipTimes)),'.');
    hold on;
    colors = hsv(length(stimfiles));
    for iStim = 1:length(stimfiles)
        correctedSwaps =  swapsTest{iStim};
        plot(correctedSwaps,(iStim+1)*ones(size(correctedSwaps)),'.','Color',colors(iStim,:))
    end
    set(gca,'YLim',[0 100])
    title(tprname);
% end


% this function creates a time vector of 0s, and 1s where stimulus exists
function [stimVector mdflips] = buildStimVector(stimTimes,mdflips)
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