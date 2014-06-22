function densityDir(xx,yy,varargin)

params.sigma = 40;
params.cont = 10;
params.contour = 0;
params.scatter = 1;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

xi = 0:5:max(xx);
yi = 0:5/max(xx):max(yy);
[x,y] = meshgrid(xi,yi);
D = 0;
sigmax = params.sigma;
sigmay = sigmax /max(xx);

for i = 1:length(xx);
    D = D+exp(- (((x-xx(i)).^2)/sigmax^2+((y-yy(i)).^2)/(sigmay^2))/2);
end

if params.scatter
    imagesc(xi,yi,D/2*pi*(max(yy)/max(xx)));
    set(gca,'Ydir','normal');
    colormap (1-0.7*gray);
    hold on;
    plot(xx,yy,'r.','MarkerSize',2);
    
else
    if params.contour
        contour(xi,yi,D/2*pi*(max(yy)/max(xx)),params.cont);
    else
        imagesc(xi,yi,D/2*pi*(max(yy)/max(xx)));
    end
    
end