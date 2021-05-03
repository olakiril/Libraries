function plotArrows(Input,varargin)
% Input -> square 2D matrix

% set default params
params.exp = 1;
params.names = arrayfun(@num2str,1:length(Input),'uni',0);
params.FontSize = 15;
params.FontColor = [0 0 0];
params.Color = [0 0 0];
params.figure = [];
params = getParams(params,varargin);

% define arrow locations
n = length(Input); theta = linspace(0.1, 2*pi - 2*pi/n + 0.1 , n); 
x = (cos(theta)/2 + 0.5)*.9+0.05; y = (sin(theta)/2 + 0.5)*.9+0.05;

% set combinations of arrows sorted by weights
[idx1,idx2] = meshgrid(1:n,1:n);idx1 = idx1(~diag(ones(n,1)));idx2 = idx2(~diag(ones(n,1)));
[weights,sort_idx] = sort(Input(sub2ind(size(Input),idx1,idx2)).^params.exp);weights = weights/max(weights(:));
idx1 = idx1(sort_idx); idx2 = idx2(sort_idx);

% scaling of the arrows to minimize clutter
scalefun = @(x) ((x - mean(x)).*[0.75,0.85] + mean(x)); 

% define arrow function
arrowfun = @(x1,y1,x2,y2,w) annotation('arrow',...
    scalefun([x1,x2]) + (cos(pi - atan2((x2-x1),(y2-y1))))*0.01, ...
    scalefun([y1,y2]) + (sin(pi - atan2((x2-x1),(y2-y1))))*0.01,'headStyle','cback1',...
    'HeadLength',(5+10*w),'HeadWidth',(10+4*w),'linewidth',4*w,'color',hsv2rgb([rgb2hsv(params.Color)*[1,0,0]',w,1-w*0.8]));

% plot
if isempty(params.figure);params.figure = figure;end;set(params.figure,'color',[1 1 1],'name','Arrow plot')
ax = arrayfun(arrowfun,x(idx1),y(idx1),x(idx2),y(idx2),weights');
arrayfun(@(x) set(x,'parent',gca),ax);
arrayfun(@(x,y,name) text(x,y,name,'FontSize',params.FontSize,'Color',params.FontColor,...
    'HorizontalAlignment','center','VerticalAlignment','middle'),x,y,params.names)
axis image, axis off

end





