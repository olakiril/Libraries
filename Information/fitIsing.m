function [theta, p, m, C, H] = fitIsing(ptarget,order)

% [h, J, p, m, C] = fitIsing(ptarget)
%   Fits an Ising model of second order for binary data to an empirical
%   distribution ptarget. For fitting, conjugate gradient descent on the
%   negative log likelihood is used. 
%
%   Inputs:
%       ptarget     target probability mass function (estimated from data)
%
%   Outputs:
%       theta       parameter values
%       p           probability mass function of the Ising model
%       m           mean of Ising model distribution
%       C           covariance of Ising model distribution
%       H           entropy of Ising model
%
%   Note: To obtain h, J for 2nd order model, use fromTheta.
%
% PHB 2007-08-01

% dimension of data
D = log2(length(ptarget));

% size/initialization of parameter vector 
N = 0; for i = 1:order, N = N + nchoosek(D,i); end
theta = zeros(N,1);

% optimization of model parameters using cg
theta = minimize(theta,'isingLogLik',1e10,ptarget,order);

% computation of model statistics
[p, m, C, H] = isingStats(theta, order);



