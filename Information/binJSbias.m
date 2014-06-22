function js = binJSbias(S1,S2)

N = size(S1,2);        
M = fix(N * [1 0.5 0.25 0.125]);

idx = randperm(N);

js = zeros(length(M),1);

for m = 1:length(M)
  
  L = fix(N/M(m));
  l1 = zeros(1,L);
  
  for l = 1:L
    d = sort(idx((l-1)*M(m) + (1:M(m)))); 
    p = binHist(S1(:,d),false);
    q = binHist(S2(:,d),false);
    
    l1(l) = binJS(p,q,M(m));
  end 
  js(m) = mean(l1);
end

% fit with quadratic function
J = 1./M';
beta = regress(js,[J.^2 J ones(size(J))]);

% extrapolate to infinity
js = beta(3);
