function out = computeImage(a,z,varargin)

params.pos = [];
params.sd = 3;

params = getParams(params,varargin);

mu = a(1:2)';

if params.pos
    mu(1) = (mu(1)*size(z,2))/params.pos(1);
    mu(2) = (mu(2)*size(z,1))/params.pos(2);
end

C=diag(a(3:4)); C(1,2)=a(5); C(2,1)=a(5);
[x,y] = meshgrid(1: size(z,2),1: size(z,1));

X=[x(:) y(:)];

X = bsxfun(@minus, X, mu);
d = sum((X /C) .* X, 2);

z = reshape(z,[],size(z,3));
out = z(d < params.sd,:);




