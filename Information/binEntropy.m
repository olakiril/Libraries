function H = binEntropy(S)
% H = binEntropy(S)
%   computes Entropy for binary sample in S or histogram S
%   S: D*N or 1*N (and non binary) (the latter is interpreted as a histogram)
%
% PHB 2007-06-11

% check input format
if size(S,1)==1 
    hc = S;
else
    hc = binHist(S);
end

pc = hc/sum(hc);
idx = pc~=0;
H = -sum(pc(idx).*log2(pc(idx)));