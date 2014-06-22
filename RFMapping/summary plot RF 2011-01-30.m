params.rf_opt_num = 6;
params.trace_opt = 2;

[snr p dotSize stimFrames] = fetchn(RFStats(params,'mouse_id = 114 or mouse_id = 116')*RFFit, ...
    'snr','onpoff_p','dot_size','stim_frames');

stims = [dotSize stimFrames];
uni= unique(stims,'rows');

for iUni = 1:size(uni,1)
    snrP(iUni) = mean(snr(prod(stims')' == prod(uni(iUni,:)))>1.5);
    pP(iUni) = mean(p(prod(stims')' == prod(uni(iUni,:)))<0.05);
end

a = uni;
a(:,4) = pP';
a(:,3) = snrP';