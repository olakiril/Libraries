function balls(X,Y,Z,C,varargin)

params.size = 5; % normalized %
params.points = 30;
params.colormap = 'hsv';
params.names = {'X','Y','Z'};

params = getParams(params,varargin);

if nargin<4 || isempty(C)
    C = ones(size(X));
elseif length(C)<length(X) && length(C) == 1
    C = ones(size(X))*C;
end

range = max([max(X) - min(X) max(Y) - min(Y) max(Z) - min(Z)]);
bsize = range*params.size/100;

[x,y,z] = sphere(params.points);

hold on
for iball = 1:length(X)
    surf(...
        x*bsize+X(iball),...
        y*bsize + Y(iball),...
        z*bsize+ Z(iball),...
        ones(size(x))*C(iball))  % sphere centered at origin
end

eval(['colormap = ' params.colormap ';'])
shading interp
% camlight('right')
% lighting gouraud

xlabel(params.names{1});
ylabel(params.names{2});
zlabel(params.names{3});
axis equal
