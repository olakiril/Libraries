function [gim mask] = gaussmask(im,pos,diam,varargin)

% function [gim mask] = gaussmask(im,pos,diam,varargin)
%
% masks an image with a gaussian window at the position (pos = [x y]) of the image with
% a specified diameter in pixels (diam) and std specified by alpha (look
% gausswin)
%
% MF 2012-03

params.alpha = 2.5;
params.mask = 1;

params = getParams(params,varargin);

if nargin<3
    display('Not enough inputs!')
end

if ~params.mask
    sz = size(im)*2;
else
    sz = size(im);
end

% find unused areas
more = -size(im) + fliplr(pos) + round(sz/2);
more(more<0) = 0;
less = - fliplr(pos) + round(sz/2);
less(less<0) = 1;

if ~params.mask
    % create mask
    mask = zeros(size(im)*2);
    mask(round(size(mask,1)/2 - diam/2) : round(size(mask,1)/2 + diam/2 - 1),...
        round(size(mask,2)/2 - diam/2): round(size(mask,2)/2 + diam/2 -1)) =...
        gausswin(diam,params.alpha)*gausswin(diam,params.alpha)';
    mask = normalize(mask);
    
    % find overlaping indexes
    mask = mask(less(1) : end - more(1)-1, less(2) : end - more(2)-1);
    
else
    % create a circular mask with center the given and radius(r) the maximum
    % overlap
    r = floor(diam/2) - max([less(:);more(:)]);
    [x y] = meshgrid(1:size(im,2),1:size(im,1));
    mask = (((x-pos(1)).^2 + (y-pos(2)).^2) <  r^2 );
    mask = convn(mask,gausswin(diam,params.alpha)*gausswin(diam,params.alpha)','same');
    mask = normalize(mask);    
end

% filter image
gim = im.*mask;

if ~nargout
    figure;
    colormap gray
    imagesc(gim)
end