function im = osphere(d,sz)

% function im = osphere(d,mx)
%
% creates a 3D matrix of ones in the shape of a sphere
% d : diameter (pixels)
% sz: size of the matrix
%
% MF 2012-02-06


[xi,yi,zi] = ndgrid(0:1:sz-1 ,0:1:sz-1 ,0:1:sz-1);
thr = sqrt(((d*(sz/2/size(xi,1)))^2));
im = zeros(size(xi));
io = sqrt((xi-sz/2).^2 + (yi-sz/2).^2 + (zi-sz/2).^2) ;
im(io <=thr) = 1;
