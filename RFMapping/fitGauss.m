function [par, sse] = fitGauss(z,varargin)

params.gausswin = 35; % in visual degrees
params.deg2dot = 0.18;

params = getParams(params,varargin);

% apply smoothing
w = window(@gausswin,round(params.gausswin*params.deg2dot));
w = w * w';
w = w / sum(w(:));
z = imfilter(z,w,'circular');

[x,y] = meshgrid(1:size(z,2),1:size(z,1));

x = x(:); y = y(:); z = z(:);
x = [x y]'; 

[amp, i] = max(z);
base = prctile(z,10);

par = zeros(7,1);
par(1:2) = [x(1,i) x(2,i)]; 
par(3:4) = [1 1]; 
par(5) = 0; 
par(6) = amp - base; 
par(7) = base;

% lb = [-inf -inf 0 0 -inf 0 -inf];
lb = [-inf -inf 0.25 0.25 -0.5 0 -inf];
ub = [inf inf 100 100 0.5 inf inf];
opt = optimset('Display','off','MaxFunEvals',1e20,'MaxIter',1e3);
[par, sse] = lsqcurvefit(@Gauss,par,x,z',lb,ub,opt);


function z = Gauss(par,x)

m = par(1:2);
C = diag(par(3:4));
cc = par(5) * sqrt(prod(par(3:4)));
C(1,2) = cc;
C(2,1) = cc;

xx = bsxfun(@minus,x,m);
z = exp(-.5*sum(xx.*(inv(C)*xx),1)) * par(6) + par(7);

