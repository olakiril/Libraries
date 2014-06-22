function c = ncorr(traces)

% function c = ncorr(traces)
% 
% this function calculates the noise correlations between the cells
% trace = [cells stimuli trials]

ztraces = zscore(traces,[],3);

mcorr = corr(ztraces(:,:)');

c = nanmean(mcorr(logical(tril(ones(size(mcorr)),1))));