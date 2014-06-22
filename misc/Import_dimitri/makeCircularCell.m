function [g, dg] = makeCircularCell(xi,yi,w)
% a normalized circularly symmetric blob of the form:
%    g = g(a,x,y,radius,shape) = a*exp(-((x^2+y^2)/radius)^(sp*shape/2))
% and its derivatives, if requested.
% With sp=0.1,  shape = 20 results in a gaussian blob

sp = 0.1;  % shape scale to reduce the contribution of the shape to gradient
a  = w(1);
x  = w(2)-xi;
y  = w(3)-yi;
radius = w(4);
shape  = w(5)*sp;

dd = (x.^2+y.^2)/radius.^2;
g = a*exp(-dd.^(shape/2));

if nargout > 1
    % compute gradient if requested
    gddp1 = dd.^(shape/2-1).*g;
    gddp2 = gddp1.*dd; 
    dg.da = g/a;
    dg.dx = -shape*x/radius^2.*gddp1; 
    dg.dy = -shape*y/radius^2.*gddp1;
    dg.ds = shape/radius*gddp2;
    dg.dp = -0.5*sp*log(dd).*gddp2;
    dg.dp(isnan(dg.dp))=0;  % division by zero that should be zero, computed in the limit
end