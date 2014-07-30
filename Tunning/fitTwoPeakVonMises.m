function w = fitTwoPeakVonMises( y )
% approximates y = w(1) + w(2)*exp( w(4)*cos(x-w(5)) ) + w(3)*exp( w(4)*cos(x-w(5)+pi) )
% y is a row vector of length N containing average responses at x = 2*pi*n/N
ymin = min(y);
y = y-ymin;
[ymax,jmax] = max(y);
ymax = max(abs(y));
y = y/ymax;  %bring all units to the same scale

N = length(y);
n = 0:N-1;
x = 2*pi*n/N;

% seed solution
w(1) = 0;
w(2) = exp(-1);
w(3) = exp(-1);
w(4) = 3;
w(5) =  jmax/N*2*pi;  % preferred direction

minbound(1) = -1;
maxbound(1) = 2;
minbound(2) = 0;
maxbound(2) = 2;
minbound(3) = 0;
maxbound(3) = 2;
minbound(4) = 0;
maxbound(4) = 20;
minbound(5) = w(5) - 1.5*pi;
maxbound(5) = w(5) + 1.5*pi;

% execute optimization (minimize the residual)
options = optimset('GradObj','on','MaxIter', 500, 'TolX', 1e-6 );  %insert 'ShowStatusWindow','on' to see the course of optimization 

w = fmincon( @(w) get2PvMResidual(x, y, w), w, [],[],[],[], minbound,  maxbound, [], options );
w(5) = mod(w(5),2*pi);
w(1:3) = w(1:3)*ymax;
w(1) = w(1) +ymin;



function [L, grad] = get2PvMResidual( x, y, w )
x = x-w(5);
cos1 = cos(x);
exp1 = exp(w(4)*cos1);

yhat =  w(1) + w(2)*exp1 + w(3)./exp1;
r = y - yhat;
L = sum(r.^2);

if nargout > 1
    dy = zeros(5,length(y));
    dy(1,:) = 1;
    dy(2,:) = exp1;
    dy(3,:) = 1./exp1;
    dy(4,:) = cos1.*(w(2)*exp1 - w(3)./exp1);
    dy(5,:) = w(4)*sin(x).*(w(2)*exp1 - w(3)./exp1);
    grad = -2*dy*r';
end
