function rectangle1(xc,yc,w,h,th,varargin)

params.color = [0 0 0];
params.linewidth = 2;

params = getParams(params,varargin);

x=-w/2;y=-h/2; %corner position
xv=[x x+w x+w x x];yv=[y y y+h y+h y];

%rotate angle alpha
R(1,:)=xv;R(2,:)=yv;
alpha=th*pi/180;
XY=[cos(alpha) -sin(alpha);sin(alpha) cos(alpha)]*R;
plot(XY(1,:)+xc,XY(2,:)+yc,'color',params.color,'linewidth',params.linewidth);
