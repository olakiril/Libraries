function kl = binKullbackLeibler(hc1,hc2)
% kl = binKullbackLeibler(hc1,hc2)
%   computes kl-divergence between histograms for binary data
%   where hc1 is taken to be the true distribution
%
% PHB 2008-02-13

% normalize if not normalized
if abs(sum(hc1)-1)>1e-5 && abs(sum(hc2)-1)>1e-5
    hc1 = hc1/sum(hc1);
    hc2 = hc2/sum(hc2);
end

idx = hc1~=0;

if any(size(hc1)~=size(hc2))
  hc2 = hc2';
end

kl = sum(hc1(idx).*log2(hc1(idx)./hc2(idx)));
          