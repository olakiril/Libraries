function KL = kldiv2(d1,d2,alfa)

% 2 dimensional kl divergence
% input [bins, dims]
if nargin<3
    alfa = eps; % scalling factor
end
cv1 = cov(d1)+eye(size(d1,2),size(d1,2))*alfa;
cv2 = cov(d2)+eye(size(d1,2),size(d1,2))*alfa;
m1 = mean(d1)';
m2 = mean(d2)';
KL = (0.5 *(log(det(cv2)/det(cv1)) + sum(diag(inv(cv1)*cv2)) + (m2-m1)'*inv(cv2)*(m2-m1) - size(d1,2))+ ...
    0.5 *(log(det(cv1)/det(cv2)) + sum(diag(inv(cv2)*cv1)) + (m1-m2)'*inv(cv1)*(m1-m2) - size(d1,2)))/2;