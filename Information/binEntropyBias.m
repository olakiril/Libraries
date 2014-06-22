function kl = binEntropyBias(S)

N = size(S,2);        
M = fix(N * [1 0.5 0.25 0.125]);

idx = randperm(N);

h = zeros(length(M),1);

for m = 1:length(M)
  
  L = fix(N/M(m));
  l1 = zeros(1,L);
  
  for l = 1:L
    d = sort(idx((l-1)*M(m) + (1:M(m)))); 
    p = binHist(S(:,d),true);
    
    l1(l) = binEntropy(p);
  end 
  h(m) = mean(l1);
end

% fit with quadratic function
J = 1./M';
beta = regress(h,[J.^2 J ones(size(J))]);

% extrapolate to infinity
kl = beta(3);
