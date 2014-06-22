function [lik grad] = isingLogLik(theta,phat,order)

% [lik grad] = isingLogLik(theta,phat,order)
%   Evaluates the negative log likelihood of an Ising Model second or third
%   order at parameter values theta for the target density phat. Also
%   computes the gradient. Implementation uses logical arrays to represent
%   features and for high dimensional data, evaluates model in blocks.
%   Parameters may be set for maximal performance (see below).
%
%   Input:
%       theta   current parameter vector
%       phat    target density
%       order   order of the model (valid [2]/3)
%
%   Output:
%       lik     negative log likelihood
%       grad    gradient with respect to theta
%
% PHB 2008-08-01

persistent ISINGFEAT

% order of model (second/third)
if nargin < 3 
    order = 2;
end

% check order
if nargin==3 && (order > 3 || order < 2)
    error('Only Models of Order 2 or 3 are allowed')
end

% number of dimensions
n = log2(length(phat));

% compute features only if needed (i.e. once at the beginning)
% for efficiency ISINGFEAT is a logical matrix
if (isempty(ISINGFEAT) || ...
    size(ISINGFEAT,2)~=length(phat) || ...
        size(ISINGFEAT,1)~=length(theta))
    ISINGFEAT = isingFeature(n,order);
end

% evaluate ising model
if n < 19  % dimensions at which to start using blocks: adjust to memory size
    
    p = exp(ISINGFEAT'*theta); 
    p = p/sum(p);
    model = ISINGFEAT * p;
    data = ISINGFEAT * phat;

else
    
    % split in blocks (memory issues)
    bz = 2^17;              % block size: adjust to memory avaiability
    np = length(phat);
    
    p = zeros(np,1);
    model = zeros(size(ISINGFEAT,1),1);
    data = zeros(size(ISINGFEAT,1),1);
    
    % iterate over blocks
    for t=1:np/bz
        idx = (1:bz)+(t-1)*bz;
        p(idx,1) = exp(ISINGFEAT(:,idx)'*theta);
        model = model + ISINGFEAT(:,idx) * p(idx);
        data = data + ISINGFEAT(:,idx) * phat(idx);
    end
    Z = sum(p);
    p = p/Z;
    model = model / Z;
    
end

% compute likelihood
lik = -sum(phat.*log(p));

% compute gradient
grad = -data+model;
