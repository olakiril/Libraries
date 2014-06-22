function SNR = computeRFsnr(a,z)

mu = a(1:2)';
C=diag(a(3:4)); C(1,2)=a(5); C(2,1)=a(5);
[x,y] = meshgrid(1:size(z,2),1:size(z,1));

X=[x(:) y(:)];

X = bsxfun(@minus, X, mu);
d = sum((X /C) .* X, 2);

z = reshape(z,[],size(z,3));
noise = var(z(d > 3,:),[],1);
sig = var(z(d < 3,:),[],1);
SNR = sig ./ noise;
% sig = mean(z(d < 3)) - mean(z(d > 3));
% SNR = sig / sqrt(noise);


