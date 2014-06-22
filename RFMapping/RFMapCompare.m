function RFMapCompare(params)

%%
params.stim_frames=15;
params.dot_size=120;
params.exp_date='2010-11-01';
params.rf_opt_num =7;

snr1100 = fetchn(RFFit(params),'snr');
params.stim_frames=8;
snr2100 = fetchn(RFFit(params),'snr');


params.stim_frames=15;
params.dot_size=120;
params.exp_date='2010-11-01';
params.rf_opt_num =8;

snr125 = fetchn(RFFit(params),'snr');
params.stim_frames=8;
snr225 = fetchn(RFFit(params),'snr');


params.stim_frames=15;
params.dot_size=120;
params.exp_date='2010-11-01';
params.rf_opt_num =7;

snr150 = fetchn(RFFit(params),'snr');
params.stim_frames=8;
snr250 = fetchn(RFFit(params),'snr');


params.stim_frames=15;
params.dot_size=120;
params.exp_date='2010-11-01';
params.rf_opt_num =9;

snr175 = fetchn(RFFit(params),'snr');

params.stim_frames=8;
snr275 = fetchn(RFFit(params),'snr');