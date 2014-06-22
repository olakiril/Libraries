function [theta] = toTheta(h,J)

theta = [h; 2*J(triu(ones(size(J)),1)==1)];