function [p,v,N] = binHist(S,bayes)

% [p,v,n] = binHist(S)
%   Bayesian estimation of the histogram of a binary distribution with a 
%   Dirichlet prior. If bayes is false, raw histogram is returned.
%
%   Returns p, the expected histogram, v, the variance of the histogram and
%   n the number of samples.
%
%   PHB 2011-03-14

if nargin < 2
  bayes = true;
end

[D N] = size(S);        % number of samples
C = binBinaryToDec(S);  % to decimal numbers

% count number of occurences and add prior if desired
a = countElem(C,0,2^D); 

if bayes
  a = a + 1;    
end

a0 = sum(a);

% expected histogram
p = a / a0;

% variance of histogram
if bayes
  v = a.*(a0-a) / (a0^2 * (a0+1)); 
else
  v = NaN(size(p));
end







