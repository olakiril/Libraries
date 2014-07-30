function [inCorr inCorrP] = traceCorr(trace)
% trace is = [cells classes trials]


traceZ = zscore(trace,[],2);

% calculate all combinations of correlations


% get the index of the same movie trials
% trialIn = find(movieTypes(:,iMovie));
% trialOut = find(~movieTypes(:,iMovie));

% compute permuted correlations
cmbIn = combnk (1:size(trace,3),2);
% cmbOut = setxor(setxor(combnk([trialIn;trialOut],2), ...
%     cmbIn{iMovie},'rows'),combnk(trialOut,2),'rows');
% randOut = randperm(size(cmbOut{iMovie},1));
% cmbOut = cmbOut{iMovie}(randOut(1:size(cmbIn{iMovie},1)),:);

% Correlate and calculate significance
for iCell = 1:size(trace,1)
[inCorr(iCell) inCorrP(iCell)] = corr(reshape(traceZ(iCell,:,cmbIn(:,1)),[],1),...
    reshape(traceZ(iCell,:,cmbIn(:,2)),[],1));
end
% [outCorr outCorrP] = corr(reshape(traceZ(:,cmbOut(:,1)),[],1),...
%     reshape(traceZ(:,cmbOut(:,2)),[],1));
