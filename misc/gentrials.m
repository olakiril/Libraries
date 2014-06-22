function ntraces = gentrials(m,v,t)

% function ntraces = gentrials(m,v,t)
%
% gentrials generates trials sampled from normal distribution
%
% m: mean, v: variance, t: trials
%
% MF 2011-08-21

old_size = size(m);

m = reshape(m,[],1);
v = reshape(v,[],1);
v = sqrt(v);

ntraces = nan(size(m,1),t);

for i = 1:length(m)
    
    ntraces(i,:) = normrnd(m(i),v(i),[1 t]);
    
end

ntraces = reshape(ntraces,[old_size t]);