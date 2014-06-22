function rfsnrcom(varargin)

params.min = 0.05;
params.max = 10;
params.opts = [1 2 3 4 5];

params = getParams(params,varargin);

c = {params.opts params.opts};
[c{:}]=ndgrid(c{:});
c = unique(sort(reshape(cat(length(c)+1,c{:}),[],length(c)),2),'rows');
c(c(:,1) == c(:,2),:) = [];

for icase = c'
    figure
    snr = cell(2,1);
    name = cell(2,1);
    for idx = 1:2
        key.trace_opt = icase(idx);
        snr{idx} = fetchn(RFFit('rf_opt_num = 6 and stim_frames = 15 and dot_size = 120 and stim_idx = 1') ...
            .*Traces(key),'snr');
        name{idx} = fetch1(TracesOpt(key),'trace_computation');
    end
    indx = snr{1}>params.min & snr{1} <params.max & snr{2} >params.min & snr{2}<params.max;
    regressPlot(snr{1}(indx),snr{2}(indx),'midline',1,'xname',name{1},'yname',name{2});
end



