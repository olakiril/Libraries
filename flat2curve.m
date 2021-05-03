function [I_curved, transform] = flat2curve(I, dist, mon_size, varargin)

% function [I_curved, tranform] = flat2curve(I, dist, mon_size, varargin)
%
% flat2curve corrects the image for flatness of the monitor
%
% INPUTS
% dist: minimum distance to screen in cm
% mon_size: diagonal of the monitor in inches
%
% OUTPUTS
% I_curved: Corrected image
% tranform: Transformation function
%   for 'index'  : pixel indexing
%   for 'interp' : interpolation

params.center_x = 0;  % point of x in normalized x coordinates from center
params.center_y = 0;  % point of y in normalized x coordinates from center
params.method = 'index';
params = getParams(params,varargin);

%Shift the origin to the closest point of the image.
nrows = size(I,1);
ncols = size(I,2);
[xi,yi] = meshgrid(1:ncols,1:nrows);
xt = xi - ncols/2 - params.center_x*ncols;
yt = yi - nrows/2 - params.center_y*ncols;

% Convert the Cartesian x- and y-coordinates to cylindrical angle (theta) and radius (r) coordinates
[theta,r] = cart2pol(xt,yt);

% Compute corrected radius
diag = sqrt(sum(size(I).^2)); %  diagonal in px
dist_px = dist / 2.54 / mon_size * diag; % closest distance from the monitor in px
phi = atan(r/ dist_px);
h = cos(phi/2)*dist_px;
r_new = 2*sqrt(dist_px.^2 - h.^2);

% Convert back to the Cartesian coordinate system. Shift the origin back to the upper-right corner of the image.
[ut,vt] = pol2cart(theta,r_new);
ui = ut + ncols/2 + params.center_x*ncols;
vi = vt + nrows/2 + params.center_y*ncols;

% Tranform image
switch params.method
    case 'index'
        index = sub2ind(size(ui),round(vi),round(ui));
        transform = @(x) x(index);
    case 'interp'
        transform = @(x) interp2(x,ui,vi);  
end
I_curved = transform(I);