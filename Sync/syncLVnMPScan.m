function syncLVnMPScan(filename)

% function syncLVnMPScan(filename)
%
% Compares the two traces and synchronizes the MPScan timestamps (converts
% them to Labview times
%
% MF 2010-11-06


% get MPScan waveform and info
tp = tpReader([filename 'p%u.h5']);
tpPD = getElectrodeChannel(tp,1);
mpTrace = double(getData(tpPD));
mpFPS = getSamplingRate(tpPD);
pdRate = getSamplesPerFrame(tpPD);
times = readTimestamps(tp);

% get Labview waveform and info
if strcmp(filename(end-9:end),'101102_008')
    stimFilename = '/mnt/stor01/stimulation/Mouse2P1/2010-11-02_17-42-13/DotMappingExperiment.mat';
else
    stimFilename = findStimFileManual ( filename );
end

if isempty(stimFilename)
    display([filename ' is not correlated with any stimulation file, skipping...'])
    return
end

indx = strfind(stimFilename,'/');
lvTrace =  baseReader(getLocalPath([stimFilename(1:indx(end)-1) '/waveforms%d']));
lvFPS = getSamplingRate(lvTrace);

% correct for corrupted data
if ~lvFPS
    file = filename;
    file(end) = '2';
    stimFilename = findStimFileManual ( file );
    indx = strfind(stimFilename,'/');
    lvTrace2 =  baseReader(getLocalPath([stimFilename(1:indx(end)-1) '/waveforms%d']));
    lvFPS = getSamplingRate(lvTrace2);
end


% interpolate to fix rate differences
mpTraceCorr = interp1(mpTrace, 1:mpFPS/lvFPS:length(mpTrace), 'linear','extrap')';

% % improve traces
lvt = normalize(lvTrace(:,1));
mpt = normalize(mpTraceCorr);
lvt(lvt> 1 -  std(lvt)) = 1;
mpt(mpt> 1 -  std(mpt)) = 1;
lvt = 1 - lvt;
mpt = 1 - mpt;

% cross-correlation to find shift
cor = xcorr(lvt,mpt);
[amp indx] = max(cor);
shift = indx - max(length(lvTrace(:,1)),length(mpTraceCorr));

% inferre times
mpTimes = 0:double(pdRate):length(mpTrace)-1;
mpTimes = mpTimes/mpFPS;
mpTimes = mpTimes + abs(shift)/lvFPS;
mpTimes = mpTimes * 1000; % convert to milliseconds
mpTimes = mpTimes(1:length(times));

% save times
close(tp);
writeSyncedTimestamps([filename 'p%u.h5'], mpTimes,[]);

% % Plot
% figure
% drawnow
% plot(normalize(lvTrace(abs(shift):50:end,1)))
% drawnow
% hold on
% plot(normalize(mpTraceCorr(1:50:end)),'r')
% drawnow
% title(gca,filename);
% drawnow


function normA = normalize(a)
normA = (a - min(a))./(max(a) - min(a));
