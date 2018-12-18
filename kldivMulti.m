function KL = kldivMulti(d1,d2)
cv1 = cov(d1);
cv2 = cov(d2);
m1 = mean(d1)';
m2 = mean(d2)';

KL = (0.5 *(log(det(cv2)/det(cv1)) + sum(diag(inv(cv1)*cv2)) + (m2-m1)'*inv(cv2)*(m2-m1) - 2)+ ...
0.5 *(log(det(cv1)/det(cv2)) + sum(diag(inv(cv2)*cv1)) + (m1-m2)'*inv(cv1)*(m1-m2) -2))/2;