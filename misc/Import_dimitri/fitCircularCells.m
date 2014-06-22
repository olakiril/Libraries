% fitCircularCells 
% Dimitri Yatsenko.  2009-05-19

function [cells, cleanImg, residual] = fitCircularCells( img, varargin )
% fits the 2D image 'img' with radially symmetric convex cell templates
%
% Returns position and shape information in structure 'cells'
% Returns the residual image in 'residual'
%
% See the params structure below for the 

params = struct( ...
    'minRadius', 8, ...       % min cell radius to match.  8 is good for lens*mag=60.  Scale proportionately.
    'minDistance', 24, ...    % min distance between cell centers in the initial seed solution. 20 is good for lens*mag=60. Scale proportionately.
    'maxCells', 120, ...       % number of cells in the seed solution (before rejection)
    'fitThreshold', 0.85, ...  % the lowest correlation between the data and the fit to accept as a match.  0.85-0.95 works well
    'ampThreshold', 0.35);     % the lowest amplitude to accept as a match as a fraction of the top quantile of matches.  0.3-0.7 works well

for i=1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

fprintf('fitCircularCells:  minRadius =  %2.2f, minDistance = %2.1f, maxCells = %d, fitThreshold = %1.2f, ampThreshold = %1.2f\n'...
    , params.minRadius, params.minDistance, params.maxCells, params.fitThreshold, params.ampThreshold);

% translate to log domain to equalize contrast
img = log(img);

% remove the background
k = hamming(2*round(2.0*params.minDistance)+1); 
k=k/sum(k);
img1 = img -imfilter( img, k*k', 'symmetric' );

% produce first seed solution
w = getInitialFit( img1, params.minRadius, params.minDistance, params.maxCells );

% subtract first seed solution and refine the background
[xi,yi] = meshgrid(1:size(img,2),1:size(img,1));
img2 = img;
for i=1:length(w)/5
    ww = w((i-1)*5+(1:5));
    reach = 1.2*ww(4);
    idx = find( (xi(:) - ww(2)).^2 + (yi(:) - ww(3)).^2 < reach.^2 );
    g = makeCircularCell(xi(idx),yi(idx), ww );
    img2(idx) = img2(idx) - g;
end

% subtract refined background
k = hamming(2*round(1.0*params.minDistance)+1); 
k=k/sum(k);
bg = imfilter( img2, k*k', 'symmetric' );
cleanImg = img - bg;

% produce the second seed solution
[w,relevant_pixels] = getInitialFit( cleanImg, params.minRadius, params.minDistance, params.maxCells );
fprintf('Produced a seed solution with %d cells\n', length(w)/5);

% set optimization parameters
minbound = w;
maxbound = w;
idx = 0:5:length(w)-1;
minbound(idx+1) = 0.5*minbound(idx+1); % the min amplitude is  50% of the initial match
maxbound(idx+1) = 1.1*maxbound(idx+1); % the max amplitude is 110% of the initial match
minbound(idx+2) = minbound(idx+2) - params.minRadius/2;  % x migration lower bound
maxbound(idx+2) = maxbound(idx+2) + params.minRadius/2;  % x migration upper bound
minbound(idx+3) = minbound(idx+3) - params.minRadius/2;  % y migration lower bound
maxbound(idx+3) = maxbound(idx+3) + params.minRadius/2;  % y migration lower bound
minbound(idx+4) = params.minRadius;
maxbound(idx+4) = 0.8*params.minDistance;  % the maxium radius is 70% of the min distance between cell centers 
minbound(idx+5) = 40;
maxbound(idx+5) = 120;
hessPattern = speye(length(w));  % helps speed up optimization
for i=0:5:length(w)-1
    hessPattern(i+(1:5),i+(1:5)) = 1;
end

% execute optimization (minimize the residual)
disp('Optimizing fit...');
options = optimset('GradObj','on','MaxIter', 50, 'TolX', 0.005*sqrt(length(w)/5), 'HessPattern', hessPattern);  %insert 'ShowStatusWindow','on' to see the course of optimization 
% isolate relevant subimage 
subxi = xi(relevant_pixels);
subyi = yi(relevant_pixels);
subimg = cleanImg(relevant_pixels);
w = fmincon( @(w) computeFitResidual(subimg, subxi, subyi, w), w, [],[],[],[], minbound,  maxbound, [], options );

% remove matches below fitThreshold
v = [];
for i=1:length(w)/5
    ww = w((i-1)*5+(1:5));
    reach = 1.1*ww(4);
    idx = find( (xi(:) - ww(2)).^2 + (yi(:) - ww(3)).^2 < reach.^2 );
    g = makeCircularCell(xi(idx),yi(idx), ww );
    fit(i) = g'*cleanImg(idx)/norm(g)/norm(cleanImg(idx));  % correlation between data and fit
    if fit(i) > params.fitThreshold 
        v = [v ww];
    end
end
fprintf('Rejected %d matches based on shape\n', (length(w)-length(v))/5);
w = v;

% reject matches below amplitude threshold
v = [];
idx = find(w(1:5:end) > params.ampThreshold*prctile(w(1:5:end),80));
for i=idx
    v = [v w((i-1)*5+(1:5))];
end
fprintf('Rejected %d matches based on amplitude\n', (length(w)-length(v))/5);
w = v;

% compute residual image if requested
if nargout > 1
    sp = 0.1;  % make sure this matches the value in makeCircularCell
    residual = cleanImg;
    for i=1:length(w)/5
        ww = w((i-1)*5+(1:5));
        epsilon = 1e5;
        reach = ww(4)^2*log(epsilon)^(2/(sp*ww(5))); 
        idx = find( (xi(:) - ww(2)).^2 + (yi(:) - ww(3)).^2 < reach );
        residual(idx) = residual(idx) - makeCircularCell( xi(idx), yi(idx), ww );
    end
end

cells.amplitude = w(1:5:end);
cells.x         = w(2:5:end);
cells.y         = w(3:5:end);
cells.radius    = w(4:5:end);
cells.shape     = w(5:5:end);




function [w,relevant_pixels] = getInitialFit( img, radius, minDistance, maxCells ) 
% get initial cell positions
% 'radius' is radius of the initial template
% the positions will be separated by at least 'minDistance'
% returns 'relevant_pixels' -- the enumeration of relevant pixels   
sp = 0.1;  %make sure it matches other definitions 
radius = round(radius);
[xi,yi] = meshgrid(-radius:radius,-radius:radius);
k = makeCircularCell( xi, yi, [1,0,0,radius,9/sp] );
k = k/sum(k(:).^2);
fit = imfilter( img, k, 'symmetric' );
ud = max( imfilter(fit,[1 0 0]','symmetric'), imfilter(fit,[0 0 1]','symmetric'));  % up/down max
lr = max( imfilter(fit,[1 0 0] ,'symmetric'), imfilter(fit,[0 0 1] ,'symmetric'));  % left/right max
peaks = find(fit >= max(0,max(ud,lr)));  % list of all peaks in the filtered image
[temp,order] = sort(-fit(peaks));
peaks = peaks(order(1:min(length(order),maxCells)));
w = [];
[y,x] = ind2sub(size(fit),peaks);
for i=1:length(peaks)-1
    if peaks(i)>0
        % record peak
        w = [w fit(peaks(i)) x(i) y(i) radius 4/sp];
        % zero out competing neighbors
        keep = (x(i)-x(i+1:end)).^2+(y(i)-y(i+1:end)).^2 > minDistance.^2;
        peaks(i+1:end) = peaks(i+1:end).*keep;
    end
end

if nargout > 1
    % isolate relevant pixels to reduce computational load
    [y,x] = ind2sub(size(img),1:prod(size(img)));
    relevant_pixels = false(prod(size(img)),1);
    for i=1:5:length(w)
        ww = w(i+(0:4));
        relevant_pixels = relevant_pixels | (x'-ww(2)).^2 + (y'-ww(3)).^2 < minDistance.^2;
    end
    relevant_pixels = find(relevant_pixels);
end 


function [L, gradL] = computeFitResidual(img, xi, yi, w)
% compute the cost functional 'L' and its gradient 'gradL' 
% select the portion of the image with significant contribution from the blob
epsilon = 1e5;
sp = 0.1;  % make sure its consistent with the value in makeCircularCell

gradL = zeros( size(w) );  % gradient vector of the cost functional

% compute residual
rr = img;  %residual
store_dg = cell(1,length(w)/5);
store_idx = cell(1,length(w)/5);
for i=1:length(w)/5
    ww = w((i-1)*5+(1:5));
    reach = ww(4)^2*log(epsilon)^(2/(sp*ww(5))); 
    idx = find( (xi(:) - ww(2)).^2 + (yi(:) - ww(3)).^2 < reach );
    [g, dg] = makeCircularCell(xi(idx),yi(idx), ww );
    rr(idx) = rr(idx) - g;
    store_idx{i} = idx; 
    store_dg{i} = dg;
end

% compute cost functional 
L = sum(rr(:).^2);

% compute gradients of the cost functional
for i=1:length(w)/5
    % compute analytical gradient
    r = rr(store_idx{i});  
    gradL((i-1)*5+1) = -2*r'*store_dg{i}.da(:);
    gradL((i-1)*5+2) = -2*r'*store_dg{i}.dx(:);
    gradL((i-1)*5+3) = -2*r'*store_dg{i}.dy(:);
    gradL((i-1)*5+4) = -2*r'*store_dg{i}.ds(:);
    gradL((i-1)*5+5) = -2*r'*store_dg{i}.dp(:);
end