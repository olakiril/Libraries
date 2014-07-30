function p = nsphere(dat)
 
dat2 = dat.^2;
p = zeros(size(dat,1),size(dat,2)-1);
 
for i = 1:size(dat,2)-1
    p(:,i) = acot(dat(:,i) ./ sqrt(sum(dat2(:,i+1:end),2)));
end