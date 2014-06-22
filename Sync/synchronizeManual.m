function [correctTptimes stimulation] = synchronizeManual( tpr, varargin )

% function [correctTpTimes stimulation] = synchronizeManual( tpr, varargin )
%
% Example:
%    [Tptimes stim] = synchronizeManual( tpr );
%
% Computes frame timestamps synchronized to the corresponding visual
% stimulus times and stores them back into the file.
% The synchronization is performed using by matching the photodiode signal to the
% frame swap times recorded in the stimulus file.
% Spits out the stimulation stracture file too.
%
% MF 2010-11-05

params.flipFreq = 30; % (Hz)
params.photodiodeSamplesPerFrame = 2000;
params.photodiodeRate  = 10000;

% find the stim file
[stimFilename  macTimes] = findStimFileManual( tpr );
assert( ~isempty(stimFilename), 'Could not find a matching stim file' );
stimFilename = getLocalPath(stimFilename);
assert( exist( stimFilename, 'file')==2, 'Could not access stim file %s', stimFilename );

% load the stimulus structure from the stim file
stim = load( getLocalPath( stimFilename ) );
stimulation = stim.stim;
times = nan(length(stim.stim.events),1);
for i = 1:length(stim.stim.events)
    times(i) = stim.stim.events(i).times(1);
end
trialT = median(diff(times));
stimT = trialT / length(stim.stim.params.conditions);
swaps = vertcat( stim.stim.params.trials.swapTimes )+ macTimes ;

% load photodiode info
pdTimes = readH5Times(tpr,'signal');
el = loadHWS(tpr,'signal','photodiode');

% calculate photodiode single frame times
photodiodeTimes = interp1(pdTimes, 1 + ((1:length(el))' / ...
    params.photodiodeSamplesPerFrame),'linear','extrap'); % s

% detect flips
disp('Detecting photodiode flips...');
flipIdx = detectFlips( double(el(:)), params.photodiodeRate , params.flipFreq );
flips = photodiodeTimes(flipIdx);

% select swap times within range of the photodiode times
blockT = flips(end) - flips(1);
swaps = swaps( swaps >= (flips(1) - blockT) & (swaps < flips(end) + blockT));
swapOffsets = swaps(diff([swaps; inf]) >= stimT);
swapOnsets  = swaps(diff([-inf; swaps]) >= stimT);

% find blocks
blockOnsets = [1; find(diff(swapOnsets) > 2*trialT)];
blockOffsets = [find(diff(swapOffsets) > 2*trialT); length(swapOffsets)]; 
blockN = sum(diff(swapOnsets) > 2*trialT) + 1 ;

fprintf( 'Found %d trials\n', sum(swapOffsets-swapOnsets > trialT/2) );
fprintf( 'whithin %d stimulus blocks\n',blockN );

% calculate tim difference
amp = nan(1,blockN);
indx = nan(1,blockN);

% calculate cross correlation between different blocks and flips
swapCell = cell(blockN,1);
for iblock = 1:blockN
    swapCell{iblock} = swaps(find(swapOnsets(blockOnsets(iblock)) == swaps): ...
        find(swaps == swapOffsets(blockOffsets(iblock))));
    cor = xcorr(swapCell{iblock},flips);
    [amp(iblock) indx(iblock)] = max(cor);
end

% select the block with the maximum correlation
[un corBlock] = max(amp); %#ok<ASGLU>
indx = indx(corBlock);
swaps = swapCell{corBlock};

% calculate the delay
swapL = length(swaps);
flipL = length(flips);
delay = indx - swapL;
minL = min(swapL - delay,flipL);
shiftTime = median(swaps(delay:minL) - flips(1:minL - delay + 1));

% find correct times
avitimes = readH5Times(tpr,'camera');
correctTptimes = avitimes + shiftTime - macTimes;


%% PLOT
% figure
% plot(flips + shiftTime,ones(length(flips),1),'.g');
% hold on
% plot(swaps,ones(length(swaps),1),'.r');


