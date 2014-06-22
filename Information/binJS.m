function js = binJS(S1,S2,N)

% [p,v,n] = binJS(S1,S2)
%   Bayesian estimation of the Jensen-Shannon divergence between two
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
  
  N = sum(S2);
  
  S1 = S1 / N;
  S2 = S2 / N;
end

M = S1/2 + S2/2;

js = 0.5 * (binKL(S1,M,N) + binKL(S2,M,N));











