cd /mnt/lab/libraries/detection/
ls
cd ../TwoPhoton/utilities/
ls
type processSpikes.m
params.width = .5;  % ms width
params.length = 5; % ms
tp
tpEl = tp.elCh{2};
time = -params.length:1000/getSamplingrate(tpEl):params.length;
filt = exp(-time.^2/params.width^2);
filt = filt / sum(filt.^2);
filt = filt - mean(filt);
%wf = filterFactory.createLowpass(5000,6000,getSamplingrate(tpEl));
wf = waveFilter(filt,getSamplingrate(tpEl));
fr = filteredReader(tpEl,wf);
plot(fr(:,1))
fft(filt)
plot(abs(fft(filt)))
wf = filterFactory.createBandpass(400,600,6000,6200,getSamplingRate(tpEl));
fr = filteredReader(tpEl,wf);
plot(fr(:,1))
getSamplingRate(tpEl)
wf = filterFactory.createBandpass(100,300,6000,6200,getSamplingRate(tpEl));
fr = filteredReader(tpEl,wf);
getSamplingRate(tpEl)
plot(fr(:,1))
plot(abs(fft(filt)))
plot((1:length(filt))/length(filt)*getSamplingRate(tpEl),abs(fft(filt)))
plot(abs(fft(filt)))
plot(fr(:,1))
wf = filterFactory.createBandpass(100,300,2000,2200,getSamplingRate(tpEl));
fr = filteredReader(tpEl,wf);
plot(fr(:,1))
wf = filterFactory.createBandpass(50,150,2000,2100,getSamplingRate(tpEl));
fr = filteredReader(tpEl,wf);
plot(fr(:,1))
wf = filterFactory.createBandpass(50,150,1000,1100,getSamplingRate(tpEl));
fr = filteredReader(tpEl,wf);
plot(fr(:,1))
size(fr)
plot(fr)
re =fr(:,1);
plot(re)
size(re)
size(e)
length(e)-length(re)
dif = ans/2;
methods(wf)
getAverageDelay(wf)
getAverageDelay(wf)/getSamplingRate(tpEl)
getFilterLength(wf)
filt
figure;
subplot(211); plot(abs(fft(filt)))
subplot(212); plot(angle(fft(filt)))
h(1) = subplot(211); plot(tpEl(:,'t'),tpEl(:)); h(2) = subplot(212); plot(fr(:,'t'),fr(:))
plot(fr(:,'t'),fr(:,1))
linkaxes(h,'x')
h(1) = subplot(211); plot(1:length(tpEl),tpEl(:)); h(2) = subplot(212); plot((1:length(fr))-getAverageDelay(wf)+getFilterLength(wf),fr(:))
h(1) = subplot(211); plot(1:length(tpEl),tpEl(:)); h(2) = subplot(212); plot((1:length(fr))-getAverageDelay(wf)+getFilterLength(wf),fr(:,1))
linkaxes(h,'x')