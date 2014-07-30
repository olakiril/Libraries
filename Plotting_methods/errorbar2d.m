function errorbar2d(x,y,varargin)

% function errorbar2d(x,y,varargin) 
%
% Computes & plots errorbars in x,y dimension
% 
% MF 2012-09-06

params.edges = []; % x edges of the computed means
params.method = 'ste'; % ste:standard error, std: standard deviation
params.errorcol = 'k';

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

if isempty(params.edges)
    params.edges = min(x):(max(x) - min(x))/10:max(x)+eps;
end

if strcmp(params.method,'ste')
    error = @(x) std(x)/sqrt(length(x));
elseif strcmp(params.method,'std')
    error = @(x) std(x);
end

[xm,ym,lx,ly,ux,uy] = initialize('nan',length(params.edges)-1,1);
for ibin = 1:length(params.edges)-1
    ind = x>=params.edges(ibin) & x<params.edges(ibin+1);
    xm(ibin) = mean(x(ind));
    ym(ibin) =  mean(y(ind));
    
    indx = y<ym(ibin) & ind;
    ly(ibin) = error(y(indx));
    
    indx = y>=ym(ibin) & ind;
    uy(ibin) = error(y(indx));
    
    indx = x>=params.edges(ibin) & x<xm(ibin);
    lx(ibin) = error(x(indx));
    
    indx = x>=xm(ibin) & x<params.edges(ibin+1);
    ux(ibin) = error(x(indx));
end

hold on

xw=(max(xm)-min(xm))/100;
yw=(max(ym)-min(ym))/100;

for t=1:length(xm)
    %x errorbars
    line([xm(t)-lx(t) xm(t)+ux(t)],[ym(t) ym(t)],'color',params.errorcol)
    line([xm(t)-lx(t) xm(t)-lx(t)],[ym(t)-yw ym(t)+yw],'color',params.errorcol)
    line([xm(t)+ux(t) xm(t)+ux(t)],[ym(t)-yw ym(t)+yw],'color',params.errorcol)

    %y errorbars
    line([xm(t) xm(t)],[ym(t)-ly(t) ym(t)+uy(t)],'color',params.errorcol)
    line([xm(t)-xw xm(t)+xw],[ym(t)-ly(t) ym(t)-ly(t)],'color',params.errorcol)
    line([xm(t)-xw xm(t)+xw],[ym(t)+uy(t) ym(t)+uy(t)],'color',params.errorcol)
end
hold off
