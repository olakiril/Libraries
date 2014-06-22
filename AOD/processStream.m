function [data raw] = processStream(raw,varargin)
% Downsample the raw stream like the FPGA does (should)
%
% JC 2010-05-20

params.throwaway = 30*4;
params.blank = 12 * 4;
params.downsample = 80;
params.samplesPerChannel = 5000;
params.channels = 2;
params = parseVarArgs(params,varargin{:});

np = params.downsample * params.channels * params.samplesPerChannel;

if strcmp(class(raw),'int32'), 
    raw = typecast(raw(1:(np + params.throwaway * params.channels)/2),'int16');
else
    raw = raw(1:np+params.throwaway * params.channels);
end

raw(1:params.throwaway * params.channels) = [];
raw = reshape(raw,[params.channels params.downsample params.samplesPerChannel]);

data = permute(sum(raw(:,params.blank+1:end,:),2),[3 1 2]);
