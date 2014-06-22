function S = binDecToBinary(X,n)
% converts numbers in row vector into a binary string of length n 
% avoid overflow!

cc = zeros(size(X));
S = zeros(n,size(X,2));
for i=n:-1:1
    idx = X>=2^(i-1);
    S(n-i+1,idx)=1;
    cc(idx) = cc(idx)+1;
    X(idx) = X(idx) - 2^(i-1);    
end