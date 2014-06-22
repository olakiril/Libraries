function [p m C H Z] = isingStats(theta,order)
% [p x m C Z] = isingStats(theta, order)
%   Computes the normalized probabilities p under the Ising model of order 
%   two or three with parameters theta by brute force enumeration of all 
%   possible states. In addition, mean, covariance and entropy are also 
%   computed.
%
%   Inputs:
%   theta   parameter vector
%   order   order of the model (valid: [2],3)
%
%   Outputs:
%   p       state probabilities
%   m       mean vector
%   C       covariance matrix
%   H       entropy
%   Z       normalizing constant
%
% PHB 2007-11-01
% PHB 2008-08-01

if nargin<2
    order =2;
end
D = findDimension(length(theta),order);
X = isingFeature(D,order);

% compute distribution & normalizing constant
if D < 18  
    
    p = exp(X'*theta); 
    Z = sum(p);
    p = p/Z;

else
    
    % split in blocks (memory issues)
    bz = 2^17;
    np = 2^D;
    
    p = zeros(np,1);
    
    % iterate over blocks
    for t=1:np/bz
        idx = (1:bz)+(t-1)*bz;
        p(idx,1) = exp(X(:,idx)'*theta);
    end
    Z = sum(p);
    p = p/Z;
  
end

% compute mean and covariance
X = X(1:D,:);
m = sum(repmat(p',D,1).*X,2);
XX = X - repmat(m,1,2^D);
C = (repmat(p',D,1).*XX)*XX';

% compute entropy
H = binEntropy(p');


% subfunction
function D = findDimension(N,order)

switch order
  case 2
      f = inline('N-D-nchoosek(D,2)','D','N');
  case 3
      f = inline('N-D-nchoosek(D,2)-nchoosek(D,3)','D','N');
end

D=10;
while true
  X = f(D,N);
  if X==0
    break
  elseif X>0
    D = D+1;
  else
    D = D-1;
  end            
end





