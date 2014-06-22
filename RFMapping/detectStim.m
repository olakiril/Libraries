function [onsets indx] = detectStim(stimFilename)

% function [onsets indx] = detectStim(stimFilename)
%
% Detects the stimulus peaks in photodiode trace
%
% MF 2010-11-06

% monitor frame rate
fps = 60;

% get waveform
indx = strfind(stimFilename,'/');
baseR =  baseReader(getLocalPath([stimFilename(1:indx(end)-1) '/waveforms%d']));

% get Sampling rate
sps = getSamplingRate(baseR);
if ~sps
    sps = 16000;
end

% calculate trace mean and std
mbase = mean(baseR(:,1));
stdbase = std(baseR(:,1));

% detect peaks
tr{1} = baseR(:,1) < (mbase - stdbase);
tr{2} = baseR(:,1) >  (mbase + stdbase);

% initialize
onsets = cell(2,1);

% iterate through positive and negative peaks
for i = 1:2
    trace = double(tr{i});
    onsets{i} = find(diff(trace)>0); 
    
    % refractory period of 10 frames
    onsets{i}(diff(onsets{i}) < 15.5*sps/fps) = [];
end

% select the sine with the maximum peaks
[un indx] = max([length(onsets{1}) length(onsets{2})]);

% convert to seconds
onsets = onsets{indx}/sps;

%% plot
% plot(baseR(:,1),'b');
% hold on
% plot(onsets{1},mbase,'.r')
% plot(onsets{2},mbase,'.g')