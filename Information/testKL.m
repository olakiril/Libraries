% test script
N = 100000;


kldiv = @(p,q) sum(p.*(log(p)-log(q)));
kl = zeros(100,1);
kltrue = zeros(100,1);

parfor i=1:100
  p = gamrnd(1,1,2^5,1)';
  p = p/sum(p);
  q = gamrnd(1,1,2^5,1)';
  q = q/sum(q);
  
  kltrue(i) = kldiv(p,q);
  
  P = binSamplesFromHist(p,N);
  Q = binSamplesFromHist(q,N);
  
  kl(i) = binKLtest(P,Q);
  
end

