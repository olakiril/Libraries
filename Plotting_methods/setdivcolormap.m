function setdivcolormap(data,cmap,linear)

if nargin<2
    cmap = 'RdBu';
end

if nargin<3
    linear = false;
end

if isstring(cmap) || ischar(cmap)
    colors = flipud(cbrewer('div',cmap,1200));
else
    colors = cmap;
end
sz = size(colors,1);
rg = range(data(:));
mn = -min(data(:));
mx = max(data(:));

mx_steps = sz*mx/2/max([mn,mx]);
mn_steps = sz*mn/2/max([mn,mx]);

if linear
    index = [max([1 sz/2-mn_steps]):sz/2 sz/2+1:sz/2+mx_steps];
else
    index = [linspace(1,sz/2,mn_steps) linspace(sz/2+1,sz,mx_steps)];
end

colors = colors(round(index),:);
colormap(colors)
