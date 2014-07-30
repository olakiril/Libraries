function fitCosine(in)

figure;
x = 1:length(in);
plot(x,in,'r');
y = in;
if length(y)<100
    y = interp(in,round(100/length(in)));
    x = interp(x,round(100/length(in)));
    x(end-round(100/length(in))+2:end) = [];
    y(end-round(100/length(in))+2:end) = [];
end
mystring = 'p(1) + p(2)*cos(theta - p(3))';
myfun = inline(mystring,'p','theta');
p = nlinfit(x,y,myfun,[1 1 0]);
hold on
yFit = myfun(p,x);
plot(x,yFit,'b')