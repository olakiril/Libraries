function [maxP, amp] = detectPeaks(traces)

% function [maxiPos amp] = detectPeaks(traces)
%
% Simple positive peak detection algorithm.
%
% MF 2012-11-21

% fix matrix if onedimentional
if numel(traces)==max(size(traces)) && size(traces,1) == 1; resh = 1;
    traces = reshape(traces,[],1);
else resh = 0;
end

amp = cell(size(traces,2),1);
maxP = cell(size(traces,2),1);

for iCol = 1:size(traces,2)
    
    % Find tops,bottoms
    wwiDiff = diff(traces(:,iCol));
    wwiDiff = wwiDiff ./ abs(wwiDiff); % binary slope
    maxiPos = diff(wwiDiff) == -2;
    miniPos = diff(wwiDiff) ==  2;
    
    % Correct for the diff shift
    maxiPos = logical([0; maxiPos; 0]);
    miniPos = logical([0; miniPos; 0]);
    
    % Detect amplitudes of the event
    maxAmp = traces(maxiPos);
    minAmp = traces(miniPos);
    
    amp{iCol} = maxAmp-minAmp;
    maxP{iCol} = find(maxiPos);
end

if numel(traces)==max(size(traces))
    amp = cell2mat(amp);
    maxP = cell2mat(maxP);
end

if resh
    amp = reshape(amp,1,[]);
    maxP = reshape(maxP,1,[]);
end