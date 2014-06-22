function cor = corrfun(matrix,cdim,tdim)

% function cor = corrfun(matrix,cdim,tdim)
%
% computes the average correlation across the specified dimention

if nargin<2;cdim = 1;end
if nargin<3;tdim = 2;end

dims = 1:length(size(matrix));

matrix = permute(matrix,[tdim cdim dims(dims~=cdim & dims~=tdim)]);

sz = size(matrix);

matrix = matrix(:,:,:);
cor = nan(1,1,size(matrix,3));
for i = 1:size(matrix,3);
    c = corr(matrix(:,:,i));
   cor(1,1,i) = mean(c(logical(tril(ones(size(c)),-1))));
end

if length(sz)>3
    cor = reshape(cor,[1,1,sz(3:end)]);
end

cor = squeeze(cor);