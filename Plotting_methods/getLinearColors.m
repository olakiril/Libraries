function colors = getLinearColors(color,n,varargin)

params.target_color = [];
params.space = 'hsv';

params = getParams(params,varargin);

if nargin<2; n = 10;end

if strcmp(params.space,'hsv')
    color = rgb2hsv(color);
end

if isempty(params.target_color)
    tg = [color(1) 0 1];
else
    tg = params.target_color;
end

if strcmp(params.space,'hsv') && ~isempty(params.target_color)
     tg = rgb2hsv(tg);
end 

colors = [linspace(color(1),tg(1),n)',...
          linspace(color(2),tg(2),n)',...
          linspace(color(3),tg(3),n)'];
if strcmp(params.space,'hsv')
    colors = hsv2rgb(colors);
end
end