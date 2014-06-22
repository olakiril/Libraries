function c_mask = imCircle(r,sz)
% function c_mask = imCircle(r,sz)
%
% Generates a circular mask of radius r with size sz
if numel(sz)<2; sz(2) = sz(1);end
cx=sz(1)/2;cy=sz(2)/2;ix=sz(1);iy=sz(2);
[x,y]=meshgrid(-(cx-1):(ix-cx),-(cy-1):(iy-cy));
c_mask=((x.^2+y.^2)<=r^2);
%  imagesc(c_mask)