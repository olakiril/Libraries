function estP = powerInference(traces)

m = mean(traces);
n = var(traces);
[b1 stats] = robustfit(m(:),n(:));

% convert to photon rates
counts = ( traces + b1(1)/b1(2) ) / b1(2);

rate = mean(counts,1);

count = reshape(counts',[],1);
count(count < 0) = 0;
power = linspace(.7,1.3,30);

%precompute some things to speed up
ratePower = bsxfun(@times,rate',power);
logRatePower = log(ratePower);
gammaCount = gammaln(1+count);
rateIdx = mod((1:length(count))-1,length(rate))+1;

%prealloxate memory and set laser drift noise
estP = zeros(length(rate),1);
estP(1) = 1;
driftSigma = .01;
for i = 2:length(count)
    % note: the LL calculation can be spead up by precomputing for each of
    % the rates (one per
    logLikelihood = -ratePower(rateIdx(i),:) - gammaCount(i) + count(i) * logRatePower(rateIdx(i),:);
    logPrior = -(power-estP(i-1)).^2 / 2 / driftSigma^2;
    post = exp(logLikelihood + logPrior); post = post / sum(post);
    estP(i) = sum(power .* post);
    %if mod(i,50000) == 0, disp(sprintf('[%u/%u]',i,length(count))); end
end

[c p] = princomp(traces);
power = mean(reshape(estP,size(traces')),1);

[traces2 t2] = aodDownsample(traces-p(:,1:2)*c(:,1:2)',time,45);
[traces3 t2] = aodDownsample(traces./reshape(estP,size(traces'))',time,45);
 
