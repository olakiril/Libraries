function kl = binKL(S1,S2,N)

% [p,v,n] = binKL(S1,S2)
%   Bayesian estimation of the Kullback-Leibler divergence between two
%   binary distribution with a Dirichlet prior. 
%
%   - S1 and S2 are supplied only: S1 and S2 have to be D x N matrices of
%     samples 
%   - S1, S2 and N are supplied: S1 and S2 are 1 x 2^D histogram vectors
%     and N is the number of samples used to estimate them
%
%   Follows Berkes et al. 2011
%
%   PHB 2011-03-14

%% check if samples or histograms have been provided
if exist('N','var')
  histo = true;
else
  histo = false;
  D = size(S1,1);
end

%% compute kl-divergence
if ~histo
  S1 = binBinaryToDec(S1);
  S1 = countElem(S1,0,2^D);
  
  S2 = binBinaryToDec(S2);
  S2 = countElem(S2,0,2^D);
else
  S1 = S1 * N;
  S2 = S2 * N;
end
  
% add prior
a = S1 + 1;    
a0 = sum(a);

b = S2 + 1;    
b0 = sum(b);

% estimate kl divergence
t1 = sum(a .* (psi(a+1) - psi(a0+1)));
t2 = sum(a .* (psi(b) - psi(b0)));

kl = 1/a0 * (t1 - t2);








