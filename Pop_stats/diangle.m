function angle = diangle(data, dim)

% function angle = diangle(data)
%
% calculates the angle from the diagonal 

if nargin<2 || isempty(dim) 
    dim = 1;
elseif dim>ndims(data)
    error('Insufficient dimensions!')
end


ang_func = @(x) abs(acosd(sum(x)./sqrt(sum(x.^2))/sqrt(size(x,1))));

data = permute(data, [dim setxor(dim,1:ndims(data))]);

angle = ang_func(data);

[~,idx] = sort([dim setxor(dim,1:ndims(data))]);

angle = permute(angle,idx);
