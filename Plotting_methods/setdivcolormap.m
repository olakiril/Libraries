function setdivcolormap(data,cmap)

if nargin<2
    cmap = 'RdBu';
end

if isstring(cmap) || ischar(cmap)
    colors = flipud(cbrewer('div',cmap,1200));
else
    colors = cmap;
end
sz = size(colors,1);
rg = range(data(:));
mn = -min(data(:))/rg;
mx = max(data(:))/rg;
mx_steps = sz*mx/2;
mn_steps = sz*mn/2;
colors = colors(round([linspace(1,sz/2,mn_steps) linspace(sz/2+1,sz,mx_steps)]),:);
colormap(colors)
