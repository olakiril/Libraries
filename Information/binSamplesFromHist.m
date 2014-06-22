function S = binSamplesFromHist(p,N)

p = p(:)';
X = bsxfun(@le,rand(N,1),cumsum(p));
S = zeros(1,N);
for i=1:N
  S(i) = find(X(i,:),1,'first')-1;  
end
S = binDecToBinary(S,log2(size(p,2)));