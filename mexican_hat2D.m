function MH = mexican_hat2D(N,IE,Se,Si,S)

% function MH = mexican_hat2D(N,IE,Se,Si,S)
%
% this script produces an N by N matrix whose values are
% a 2 dimensional mexican hat or difference of Gaussians
%

% params
if nargin<5; S=500;end %overall strength of mexican hat connectivity
if nargin<4; Si=6;end %variance of the inhibition Gaussian
if nargin<3; Se=2;end %variance of the excitation Gaussian
if nargin<2; IE=6;end %ratio of inhibition to excitation
if nargin<1; N=10;end %matrix size is NXN

[X,Y]=meshgrid((1:N)-round(N/2));
% -floor(N/2) to floor(N/2) in the row or column positions (for N odd)
% -N/2+1 to N/2 in the row or column positions (for N even)
%
[~,R] = cart2pol(X,Y);
% Switch from Cartesian to polar coordinates
% R is an N*N grid of lattice distances from the center pixel
% i.e. R=sqrt((X).^2 + (Y).^2)+eps;
EGauss = 1/(2*pi*Se^2)*exp(-R.^2/(2*Se^2)); % create the excitatory Gaussian
IGauss = 1/(2*pi*Si^2)*exp(-R.^2/(2*Si^2)); % create the inhibitory Gaussian
%
MH = S*(EGauss-IE*IGauss); %create the Mexican hat filter

