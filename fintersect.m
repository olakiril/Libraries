function [x y] = fintersect(x1,y1,x2,y2)

% function [x y] = fintersect(x1,y1,x2,y2)
%
% Finds the intersection of two functions by computing the coefficients
% from the x,y vectors.
%
% MF 2010-11-29

% function to set the greatest dimention as 1
resh = @(x) reshape(x,max(size(x)),[]);

% calculate the regression coefficents 
reg1 = regress(resh(y1),[ones(size(resh(x1))) resh(x1)])';
reg2 = regress(resh(y2),[ones(size(resh(x2))) resh(x2)])';

% compute the intersection points
x = (reg2(1) - reg1(1))/(reg1(2) - reg2(2));
y = reg1(2)*x + reg1(1);