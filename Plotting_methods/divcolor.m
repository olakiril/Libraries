function colors = divcolor(cmin, cmax, c0, map)

if nargin<4
    map = 'RdBu';
end
 
if nargin<3
    c0 = 0;
end
colors = flipud(cbrewer('div',map,100));
low_colors = colors(round(linspace(1,49,round((c0 - cmin)*100))),:,:);
high_colors = colors(round(linspace(51,100,round((cmax - c0)*100))),:,:);

if nargout
    colors = [low_colors;high_colors];
else
    colormap([low_colors;high_colors])
end


