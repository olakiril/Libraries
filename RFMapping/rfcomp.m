function rfcomp(exp_date)

params.stim_frames=15;
params.dot_size=120;
params.exp_date= exp_date;
params.rf_opt_num =6;

snr = fetchn(RFFit(params),'snr');

close all
figure
hist(snr,100)
snra2 = 100* sum(snr>=2)/length(snr);
title(['% above snr 2: ' num2str(snra2)])
set(gcf,'PaperOrientation','Landscape');
set(gcf,'PaperType','A5');
set(gcf,'PaperPositionMode','auto');
print(gcf,'-dpdf',exp_date)