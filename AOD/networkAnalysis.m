
n = aod_fastoopsi(traces,time);

step = 190;
total_spikes = cumsum(n);
binned = diff(total_spikes(1:step:end,:));

whereMyHubsAt(binned);
