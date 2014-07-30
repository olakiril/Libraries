function plotGauss(a,num)

if nargin<2
    num = 2;
end
figure;
[em_thr,em_thr_behavior,P,meanV,stdV,pdf_x,xx,pdf_xx,cdf_xx] = em_1dim(a, num);
h1 = subplot(2,1,1); hist(a, length(a)/10);
h2 = subplot(2,1,2);
color = hsv(num);
hold on;
for i = 1:num
    plot(xx, normpdf(xx, meanV(i), stdV(i)),'Color', color(i,:));
end
hold off;
a1 = axis(h1);
a2 = axis(h2);
axis(h2, [a1(1), a1(2), a2(3), a2(4)]);