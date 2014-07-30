function [ic id] = imcorr(im,varargin)

params.maxdist = floor(sqrt(size(im,1)^2 + size(im,2)^2));
params.sampleSize = 100000;

params = getParams(params,varargin);

euDist = @(x,y) sqrt(diff(x).^2 + diff(y).^2 );

x = randi(size(im,1),[2 params.sampleSize]);
y = randi(size(im,2),[2 params.sampleSize]);
dist = round(euDist(x,y));
udist = unique(dist);

[ic id] = initialize('nan',size(im,3),length(udist));
for iframe = 1:size(im,3);
    mov = im(:,:,iframe);
    for idist = 1:length(udist)
        ic(iframe,idist) = corr(...
            mov(sub2ind(size(mov),x(1,dist == udist(idist)),y(1,dist == udist(idist))))',...
            mov(sub2ind(size(mov),x(2,dist == udist(idist)),y(2,dist == udist(idist))))');
        id(iframe,idist) = udist(idist);
    end
end

% cind = nchoosek(1:numel(im(:,:,1)),2);
% [x y] = ind2sub(size(im(:,:,1)),cind);