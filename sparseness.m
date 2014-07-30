function spa = sparseness(data,varargin)

% function spa = sparseness(data,varargin)
%
% calculates the sparseness of the responses with different measures
%
% MF 2011-09-09

params.type = 'treves_roll';
params.sd = 1;

params = getParams(params,varargin);

if strcmp(params.type,'treves_roll') % Treves Roll equation
    spa = (1 - ((sum(data)/size(data,1)).^2./sum(data.^2/size(data,1))))/(1 - (1/size(data,1)));
elseif strcmp(params.type,'pzero') % probability of zero response
    spa = mean(data < repmat(std(data,[],2) * params.sd,[1 size(data,2)]),1);
elseif strcmp(params.type,'kurtosis') % kurtosis
    spa = kurtosis(data) - 3;
elseif strcmp(params.type,'unnormalized')
    spa = (1 - ((sum(data)/size(data,1)).^2./sum(data.^2/size(data,1))));
end