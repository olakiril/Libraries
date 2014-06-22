function rl = reliability(traces,donotaverage)

% function rl = reliability(traces)
% 
% Computes the variance explained:
% Reliability = True variance / Observed Variance
% Observed variance = True Variance + Error Variance
%
% x_ij = ?_i + ?_ij
%
% Var_ij[x] = Var_i[?] + Var_ij[?]
%
% VE = Var[?]/Var[x]
%
% traces can be:
% [cells time trials] or
% {cells,time}(trials)
%
% MF 2013-11

% intitialize
rl = nan(size(traces,1),1);
if iscell(traces); sz = cellfun(@length,traces); end

% loop through cells
for icell = 1:size(traces,1);
   
    if iscell(traces)
        trace = traces(icell,:);
        for istim = 1:length(trace);
            trace{istim}(end+1:max(sz(1,:))) = nan;
            trace{istim} = trace{istim}(:);
        end
        trace = cell2mat(trace);
    else trace = squeeze(traces(icell,:,:))';
    end
    
    % filter trials
    trace = trace(:,sum(~isnan(trace))>1); % has at least 3 trials
    
    % explained Variance
    rl(icell) = var(nanmean(trace,1))/nanvar(trace(:));
end

if nargin<2
    % average the VE across the cells of one site
    rl = nanmean(rl);
end