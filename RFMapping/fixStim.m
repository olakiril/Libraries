function fixStim(stimFilename)

% function fixStim(stimFilename)
%
% Finds the correct times fot the photodiode trace
%
% MF 2010-11-05

% set params
refrRate = 60;

% load the stimulation file
load(getLocalPath(stimFilename));

% get the detected onsets from the photodiode time
onsets = detectStim(stimFilename);

% iterate through each trial
corBlock = nan(1,length(stim.params.trials));
%%
for trialIndx = 1:length(stim.params.trials)

    % find the onsets that lie whithin the trial times and take the time
    % difference
    start = stim.params.trials(trialIndx).sync.response/1000; % convert to seconds
    finish = start + stim.params.trials(trialIndx).stimulusTime/1000; % convert to seconds
    onsetTimeDiff = normalize(diff(onsets(onsets > start & onsets < finish)));

    % find the locations and time length of the substimuli
    locs = [cell2mat(stim.params.trials(trialIndx).dotLocations)' ...
        cell2mat(stim.params.trials(trialIndx).dotColors)'];
    time = stim.params.trials(trialIndx).stimFrames / refrRate ;

    % find the unique locations
    uni =  unique(locs,'rows');

    % initialize
    amp = nan(1,length(uni));
    pcorr = nan(1,length(uni));

    % iterate through each location
    for locIndx = 1:length(uni)
        % calculate time differences for stim
        pos = find(sum(repmat(uni(locIndx,:),[length(locs) 1])...
            == locs,2) == size(locs,2));
        stimTimeDiff = normalize(diff(pos)*time);
        
        % calculate cross correlation between stim and photodiode to find
        % the optimal shift
        [u indx] = max(xcorr(stimTimeDiff,onsetTimeDiff));
        stimTimeDiff = circshift(stimTimeDiff,max(length(stimTimeDiff),length(onsetTimeDiff)) - indx);
        finish = min([length(onsetTimeDiff) length(stimTimeDiff)]);

        % calculate correlation
        [amp(locIndx) pcorr(locIndx)] = corr(stimTimeDiff(1:finish),onsetTimeDiff(1:finish));
%     pcorr(locIndx) = sum(abs(stimTimeDiff(1:finish)- onsetTimeDiff(1:finish)));

    end

    % select the block with the maximum correlation
    [u corBlock(trialIndx)] = min(pcorr);    
    
end

assert(length(unique(corBlock))==1);
uni(unique(corBlock),:)
assert (sum(uni(unique(corBlock),:) == [60 105 0]) ==3 || sum(uni(unique(corBlock),:) == [60 225 0]) == 3 ...
        || sum(uni(unique(corBlock),:) == [60 205 0])==3 || sum(uni(unique(corBlock),:) == [40 125 0])==3)


for trialIndx = 1:length(stim.params.trials)

    % find the onsets that lie whithin the trial times and take the time
    % difference
    start = stim.params.trials(trialIndx).sync.response/1000; % convert to seconds
    finish = start + stim.params.trials(trialIndx).stimulusTime/1000; % convert to seconds
    onsetTimes = onsets(onsets > start & onsets < finish);

    % find the locations and time length of the substimuli
    locs = [cell2mat(stim.params.trials(trialIndx).dotLocations)' ...
        cell2mat(stim.params.trials(trialIndx).dotColors)'];

    % find the unique locations
    uni =  unique(locs,'rows');
    
    % get the correct positions
    pos = find(sum(repmat(uni(corBlock(trialIndx),:),[length(locs) 1])...
            == locs,2) == size(locs,2));
        
    % built the regressor
    reg = regress(onsetTimes,[ones(size(pos)) pos])';
    stim.params.trials(trialIndx).dotTimes = ((1:length(locs))*reg(2) + reg(1))*1000;
    
end

save(getLocalPath(stimFilename),'stim')



function a= normalize(a)
a = (a - min(a))./(max(a) - min(a));