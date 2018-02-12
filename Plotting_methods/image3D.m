function image3D(x,y,z,I,inv)
I = flipud(I);
if nargin>4 && inv
    IA = abs(I-max(I(:)));
else
    IA = I;
end

%# coordinates
[X,Y] = meshgrid(1:size(I,2), 1:size(I,1));
Z = ones(size(I,1),size(I,2))*z;
X = X - size(I,2)/2 + x;
Y = Y - size(I,1)/2 + y;
%# plot each slice as a texture-mapped surface (stacked along the Z-dimension)
surface('XData',X, 'YData',Y, 'ZData',Z, ...
    'CData',I, 'CDataMapping','direct', ...
    'EdgeColor','none', 'FaceColor','texturemap',...
    'AlphaData',IA,'FaceAlpha','texturemap')


