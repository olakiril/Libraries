% function [flips,flipSign,qratio] = detectFlips( x, Fs, flipFreq )
% detect flips in a photodiode signal.
%
% INPUTS:
% x is the input signal
% Fs is the sampling frequency of x
% flipFreq is typically 30 Hz.  (60 flips per second). 
%
% OUTPUTS:
% flips contains the indices of flips in x.
% flipSign is -1 or 1 for each flip 
% qratio is the ratio of the first percentile of flip amplitude to the 99th
% percentile of non-flip amplitude. For good photodiode signal this value should be
% significanly higher than 1, e.g. >10 or even >50. 
%
% Dimitri Yatsenko 2010-09-01

function [flips,flipSign,qratio] = detectFlipsM( x, Fs, flipFreq )
T = Fs/flipFreq;  % period of oscillation measured in samples
% filter flips
n = floor(T/2);
k = hamming(n);
k = [k;0;-k]/sum(k);
x = fftfilt(k,[double(x);zeros(n,1)]);
x = x(n+1:end);
x([1:n end+[-n+1:0]])=0;
flipSign = sign(x);
x = abs(x);
% select flips
flips = spaced_max(x,0.45*T);
thresh = 0.3*quantile( x(flips), 0.99);
idx = x(flips)>thresh;
qratio = quantile(x(flips(idx)),0.01)/quantile(x(flips(~idx)),0.99);
flips = flips(idx)';
flipSign = flipSign(flips);
end