function rmat = randdim(mat,dim)

% function rmat = randdim(mat,dim)
%
% randdim randomizes order of only specified dimention (dim = 1  is
% default)
%
% MF 2011-08-20

% get input dim sequence
input_size = size(mat);
lmat = 1:length(input_size);

if nargin <2
    dim = 1;
end

% bring the rand dim in front
ndim = [dim lmat(lmat ~= dim)];
mat = permute(mat, ndim);
front_size = size(mat);

% randomize
mat = reshape(mat,size(mat,1),[]);
randindx = cell2mat(arrayfun(@randperm,ones(size(mat,2),1)*size(mat,1),'uniformoutput',0))';
class = meshgrid(0:size(mat,2)-1,0:size(mat,1)-1);
rmat = mat(randindx + class*size(mat,1));

% rehape to original dimentions
rmat = reshape(rmat,front_size);
[foo, sorti] = sort(ndim);
rmat = permute(rmat,sorti);