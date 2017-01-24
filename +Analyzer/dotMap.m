function dotMap(animal_id,session,scan_idx)

% initialize Analyzer
obj = Analyzer.Analyzer(animal_id,session,scan_idx);

% set parameters
start_offset = 100; % in milliseconds from trial start
end_offset = 700; % in milliseconds from trial start
    
init = true;
DATA = [];

while obj.run
    
    % get data
    [data, trial_key] = getTrialData(obj,start_offset,end_offset);
    if isempty(data);continue;end

    if init
        % get all condition parameters
        [allx,ally] = fetchn(vis.SingleDot & trial_key,'dot_x','dot_y');
        uallx = unique(allx);
        ually = unique(ally);
        map = zeros(length(ually),length(uallx));
        init = false; % don't init again
    end
    
    % get trial condition parameters
    [posx,posy] = fetch1((vis.Trial & trial_key)*vis.SingleDot,'dot_x','dot_y');

    % store data
    data = mean(cellfun(@(x) mean(x(:)),data)); % average all pixels for this trial
    cond_idx = find(posx==allx & posy==ally);
    DATA(end+1,:) = [cond_idx,data];
    
    % update map for shown location
    map(ually==posy,uallx==posx) = nanmean(DATA(DATA(:,1)==cond_idx,2));

    % fit & plot
    [x,y,radius] = fitBlob(map);
    drawnow

    
end
end

function [x,y,radius] = fitBlob(img)
width = size(img,2);
height = size(img,1);
img = double(img);
ys = linspace(-height/2,+height/2,size(img,1));
xs = linspace( -width/2, +width/2,size(img,2));
[yi, xi] = ndgrid(ys,xs);
img = (img - nanmin(img(:)))/(nanmax(img(:)) - nanmin(img(:)));
[contrast,i] = max(img(:));
y = yi(i);
x = xi(i);

max_aspect = 2;
lb = [-width/2, -height/2, width     ,-log(max_aspect), -pi, contrast];
ub = [+width/2, +height/2, height,+log(max_aspect), +pi, contrast];
fn = @(a) loss(xi,yi,img,a);
a = [x y 2 0 0 0.8*contrast];
try
    a = fmincon(fn, a, [],[],[],[], lb, ub, [], optimset('display','off'));
catch
    a = [nan nan nan];    
end

% assign outputs
x = a(1); y = a(2); radius = a(3);

% plot
clf
imagesc(img)
colormap gray
axis image
title([num2str(x) ' ' num2str(y)])
% axis off
hold on
rectangle('Position',[x+width/2+0.5-radius/2, y + height/2+0.5-radius/2, radius, radius],...
'Curvature',[1,1],...
'EdgeColor','r');
plot(x+width/2+0.5,y+height/2+0.5,'.r');
shg
end

function L = loss(xi, yi, img, a)
assert(length(a)==6)
D = img - fit(xi,yi,a(1),a(2),a(3)*exp(+a(4)/2),a(3)*exp(-a(4)/2),a(5),a(6));
D = D-mean(D(:));
D = D.*(1+3*(D>0));   % positive difference is penalized more
L = sum(D(:).^2);
end

function G = fit(xi,yi,x,y,ax1,ax2,theta,contrast)
xr = cos(theta)*(xi-x) + sin(theta)*(yi-y);
yr = cos(theta)*(yi-y) - sin(theta)*(xi-x);
G = contrast*exp(-(xr/ax1).^2/2-(yr/ax2).^2/2);
end