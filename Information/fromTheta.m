function [h,J] = fromTheta(theta,D)

h = theta(1:D);
theta(1:D) = [];
J = zeros(D);
J(triu(ones(D),1)==1) = theta/2;
J(tril(ones(D),-1)==1) = theta/2;