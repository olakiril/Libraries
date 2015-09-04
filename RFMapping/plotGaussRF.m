function h = plotGaussRF(m, C, sd,varargin)

params.color = [0 0 1];
params.line = '-';
params.linewidth = 1;
params.pos = []; % params.pos = [xmax1 ymax1 xmax2 ymax2];

params = getParams(params,varargin);

npts=50;

tt=linspace(0,2*pi,npts)';
x = cos(tt); y=sin(tt);
ap = [x(:) y(:)]';
[v,d]=eig(C); 
d(d<0) = 0;
d = sd * sqrt(d); % convert variance to sdwidth*sd
bp = (v*d*ap) + repmat(m, 1, size(ap,2)); 

if params.pos
    bp(1,:) = (bp(1,:)*params.pos(3))/params.pos(1);
    bp(2,:) = (bp(2,:)*params.pos(4))/params.pos(2);
end

h = plot(bp(1,:), bp(2,:),params.line,'Color',params.color,'linewidth',params.linewidth);
if nargout == 0
  clear h
end
  