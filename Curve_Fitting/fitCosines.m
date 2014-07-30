function [a2,mu2,a1,mu1,a0] = fitCosines( y )
% approximates y = a(0) + a(1)*cos( x-mu(1) ) + a(2)*cos( 2*(x-mu(2)) )
% y is a row vector of length N containing average responses for angles x = 2*pi*n/N

N = length(y);
n = 0:N-1;
x = 2*pi*n/N;
cp = exp(-2*i*x)*y'/N;  % positive frequency
cn = exp(+2*i*x)*y'/N;  % negative frequency
a2 = 2*sqrt(cp*cn);
mu2 = mod( real(i/4*(log(cp)-log(cn))), pi );

if nargout>2
    cp = exp(-i*x)*y'/N;  % positive frequency
    cn = exp(+i*x)*y'/N;  % negative frequency
    a1 = 2*sqrt(cp*cn);
    mu1 = mod( i/2*(log(cp)-log(cn)), 2*pi );
end

if nargout>4
    a0 = mean(y);
end