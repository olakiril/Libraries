function [stimfiles, tpTS, stims] = syncStim2AOD(tprname,varargin)

% function syncStim2Tpr(tprname,varargin)
%
% Synchronizes the stimulation file with the AOD file
% writes the corrected Mac times into the stim file
%
% MF 2010-11-22

params.testingmode = 0;
params.scprog = 'AOD';
params.aodReader = 'old';
params.sec2msec = 1000; % 1000 assumes that the mac times are in seconds
params =  getParams(params,varargin);
gainfix = @(x,gn,x1,xend)  (x-x1)*(1 + gn/(xend - x1)) + x1;

% get the stim files
[stimfiles, windows, macwindows, tpTS] = findStimFiles(tprname,params); %#ok<ASGLU>

% load the tpfile related data
tpTS = tpTS*1000; % convert to ms
if strcmp(params.aodReader,'new')
    br = aodReader(tprname,'Temporal');
    pd = br(:,1);
    dt = 1/br.Fs;
else
    [pd, dt] = loadHWS(tprname,'TemporalData','Photodiode');
end
pdSR = 1/dt;
pdSpF = mean(diff(tpTS))/(dt*1000);

% detect flip times
detflips = detectFlipsM(pd(:,1),pdSR,30);
flipTimes = interp1(tpTS, 1+(detflips/pdSpF),'linear','extrap'); % ms
flips = flipTimes;
stims = [];
for iStim = 1:length(stimfiles)
    
    % Load the stim file
    stimData = load(getLocalPath(strrep(stimfiles{iStim},'\','/')));
    
    % get the swapTimes for every trial
    swaps = vertcat(stimData.stim.params.trials.swapTimes)*params.sec2msec; % ms
    %     swapsL = swaps(end) - swaps(1);
    
    % Chop Times
    %     flips = flipTimes(windows{iStim}(1)- 2*swapsL < flipTimes & ...
    %         windows{iStim}(2)+ 2*swapsL > flipTimes);
    %     flipsL = flips(end) - flips(1);
    %     swaps = swaps(macwindows{iStim}(1)*1000 - flipsL < swaps & ...
    %         macwindows{iStim}(2)*1000 + flipsL > swaps);
    
    if iStim>1
        % remove flip times that have been already assigned
        utimes = cat(1,swapsTest{1:iStim-1});
        flips(flips >= min(utimes) & flips <=  max(utimes)) = [];
    end
    
    if ~params.manual
        
        gains = -200:1:200; % range of gains in ms
        amp = nan(length(gains),1); ind = amp;
        for igain = 1:length(gains);
            
            % build stim vectors
            [vswaps, mdflips] = buildStimVector(gainfix(swaps,gains(igain),swaps(1),swaps(end)));
            vflips = buildStimVector(flips,mdflips);
            
            %remove trials that are not in both vectors from the end of the traces: 2012-09-07
            dvswaps = find(diff(vswaps)>0);
            dvflips = find(diff(vflips)>0);
            trind = min([length(dvswaps) length(dvflips)]);
            vswaps = vswaps(1:dvswaps(trind));
            vflips = vflips(1:dvflips(trind));
            
            % organize..
            trace{1} = vswaps;
            trace{2} = vflips;
            [maxL, maxI] = max([length(vswaps) length(vflips)]);
            [minL, minI] = min([length(vswaps) length(vflips)]); %#ok<ASGLU>
            
            % find the optimal shift
            cor = xcorr(trace{maxI},trace{minI});
            [amp(igain), ind(igain)] = max(cor);
        end
        [~,cor] = max(amp);
        
        % correct the times
        timeCorrector = @(x) gainfix(x,gains(cor),swaps(1),swaps(end)) + ...
            flips(1) + ind(cor) - maxL - swaps(1);
        
    else
        [delay, gain] = alignVectors([flipTimes ones(length(flipTimes),1)],swaps +(tpTS(1) - swaps(1)),'marker','.');
        % correct the times
        gainfix = @(x,gn)  (x-x(1))*(1 + gn/100) + x(1);
        timeCorrector = @(x) gainfix(x + delay,gain) + tpTS(1) - swaps(1);
    end
    
   
    for iTrial = 1:length(stimData.stim.events)
        oldTimes = stimData.stim.events(iTrial).times * params.sec2msec; %ms
        stimData.stim.events(iTrial).syncedTimes = timeCorrector(oldTimes);
    end
    stimData.stim.synchronized = 1;
    stim = stimData.stim; 
    if ~params.testingmode
        % save the corrected times in the stim file3
        disp('writing synced STIM timestamps into file')
        save(getLocalPath(stimfiles{iStim}),'stim')
    end
    stims{iStim} = stim;
    swapsTest{iStim} = timeCorrector(swaps);%#ok<AGROW>
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
title(tprname);

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