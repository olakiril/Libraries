function js = binJensenShannon(hc1,hc2)
% js = binJensenShannon(hc1,hc2)
%   computes js-divergence between histograms for binary data
%
% PHB 2007-05-11

if abs(sum(hc1)-1)>1e-5 & abs(sum(hc2)-1)>1e-5
    hc1 = hc1/sum(hc1);
    hc2 = hc2/sum(hc2);
end

hc = 0.5*(hc1+hc2);

idx1 = hc~=0 & hc1~=0;
idx2 = hc~=0 & hc2~=0;

js = 0.5*(sum(hc1(idx1) .* log2(hc1(idx1)./hc(idx1))) + ...
          sum(hc2(idx2) .* log2(hc2(idx2)./hc(idx2))));
          