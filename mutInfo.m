function mi = mutInfo(TP,TN,FP,FN)

CM = zeros(2,2);
CM(1,1) = sum(TP);
CM(1,2) = sum(FN);
CM(2,1) = sum(FP);
CM(2,2) = sum(TN);

pA = CM/sum(CM(:));
pi = sum(CM,2)/sum(CM(:));
pj = sum(CM,1)/sum(CM(:));
pij = pi*pj;
if FN+FP == 0 % this is wrong, it should be FN+FP
    mi = 1;
elseif TP+TN == 0
    mi = 0;
else
    mi = sum(sum(pA.*log2(pA./pij)));
end