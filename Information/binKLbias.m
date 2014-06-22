function kl = binKLbias(S1,S2)

N = size(S1,2);        
M = fix(N * [1 0.5 0.25 0.125]);

idx = randperm(N);

kl = zeros(length(M),1);
% compute kl on fractions of data

for m = 1:length(M)
  
  L = fix(N/M(m));
  l1 = zeros(1,L);
  
  for l = 1:L
    d = sort(idx((l-1)*M(m) + (1:M(m)))); 
    p = binHist(S1(:,d),false);
    q = binHist(S2(:,d),false);
    
    l1(l) = binKL(p,q,M(m));
  end 
  kl(m) = mean(l1);
end

% fit with quadratic function
J = 1./M';
beta = regress(kl,[J.^2 J ones(size(J))]);

% extrapolate to infinity
kl = beta(3);
