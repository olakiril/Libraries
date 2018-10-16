function spa = sparseness(data,varargin)

% function spa = sparseness(data,varargin)
%
% calculates the sparseness of the responses with different measures
%
% MF 2011-09-09

params.type = 'treves_roll';
params.sd = 1;
params.dim = 1;

params = getParams(params,varargin);

if params.dim>ndims(data)
    error('Insufficient dimensions!')
end

data = permute(data, [params.dim setxor(params.dim,1:ndims(data))]);

switch params.type
    case 'treves_roll' % Treves Roll equation
        spa = (1 - ((nansum(data)/size(data,1)).^2./nansum(data.^2/size(data,1))))/(1 - (1/size(data,1)));
    case 'pzero' % probability of zero response
        spa = mean(data < repmat(std(data,[],2) * params.sd,[1 size(data,2)]),1);
    case 'kurtosis' % kurtosis
        spa = kurtosis(data) - 3;
    case 'unnormalized'
        spa = (1 - ((sum(data)/size(data,1)).^2./sum(data.^2/size(data,1))));
    otherwise
        error('Method not recognized!')
end

[~,idx] = sort([params.dim setxor(params.dim,1:ndims(data))]);
spa = permute(spa,idx);