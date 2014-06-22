function [hCells hPlanes hArrows] = Cells3D(coordinates,planeCoordinates,varargin);

params.arrows = true;
params.cube = true;
params.mot = [];
params.radius = 2;
params = parseVarArgs(params,varargin{:});

phi = linspace(0,pi,50);
theta = linspace(0,2*pi,50)';

%% plot all the cells
r = params.radius;
x = r * bsxfun(@times,cos(theta),sin(phi));
y = r * bsxfun(@times,sin(theta),sin(phi));
z = r * bsxfun(@times,cos(0*theta),cos(phi));

clf
for i = 1:size(coordinates,1)
    hCells(i) = surface(x+coordinates(i,1),y+coordinates(i,2),z+coordinates(i,3),'EdgeColor','none');
end

%% plot all the points in planes
r = 0.35;
x = r * bsxfun(@times,cos(theta),sin(phi));
y = r * bsxfun(@times,sin(theta),sin(phi));
z = r * bsxfun(@times,cos(0*theta),cos(phi));
hPlanes = [];
if isempty(params.mot)
    for i = 1:size(planeCoordinates,1)
        hPlanes(i) = surface(x+planeCoordinates(i,1),y+planeCoordinates(i,2),z+planeCoordinates(i,3),'EdgeColor','none');
    end
else
    mot = mean(params.mot(:,:,:,1:100),4);
    gridSize = size(mot,2);    
    for i = 1:(size(mot,3)/gridSize)        
        idx = (i-1)*gridSize^2+1:i*gridSize^2;
        x = reshape(planeCoordinates(idx,1),gridSize,gridSize);
        y = reshape(planeCoordinates(idx,2),gridSize,gridSize);
        z = reshape(planeCoordinates(idx,3),gridSize,gridSize);
        c = reshape(mot(1,idx),gridSize,gridSize);
        q = quantile(c(:),[.001 .999]);
        c = (c - q(1)) / range(q); 
        c(c < 0) = 0 ; c(c > 1) = 1;
        hPlanes(i) = surface(x,y,z,c*255,'FaceLighting','none','EdgeColor','none');
    end    
    colormap gray
end
%% plot arrows between points

hArrows = [];
height = 3;
body = 10;
if params.arrows 
    for i = 2:size(coordinates,1)
        dist = sqrt(sum(diff(coordinates(i-1:i,:)).^2));
        coord1 = coordinates(i-1,:);
        coord2 = coordinates(i,:);
        s(1) = height/dist;
        s(2) = .6;
        hArrows = [hArrows arrow3d(coord1,coord2,10,'cylinder',s)];
    end
end

if params.cube
    hCube(1) = patch([-100 -100 100 100],[-100 100 100 -100],[-70 -70 -70 -70],[1 1 1 1]);
    hCube(2) = patch([-100 -100 100 100],[100 100 100 100],[-70 70 70 -70],[1 1 1 1]);
    hCube(3) = patch([100 100 100 100],[-100 -100 100 100],[-70 70 70 -70],[1 1 1 1]);
    set(hCube,'FaceColor',[1 1 1]*.2,'FaceLighting','gouraud' ); 
end
%% tweak lighting

set(hArrows,'FaceLighting','phong',...
      'FaceColor',[0 0 1],...
      'EdgeColor','none',...
      'BackFaceLighting','lit')

set(hCells,'FaceLighting','phong',...
      'FaceColor',[0 1 0],...
      'EdgeColor','none',...
      'BackFaceLighting','lit');
  
if(isempty(params.mot))
    set(hPlanes,'FaceLighting','phong',...
      'FaceColor',[1 0 0],...
      'EdgeColor','none',...
      'BackFaceLighting','lit')
end

light('Position',[1 3 2]);
%light('Position',[-3 -1 3]);
material shiny
%axis vis3d off

function varargout=arrow3d(start,stop,ang,ltype,p,n)
%   Plot 3d Arrows
% 
%   This functin is used to draw 3D-arrows. The size of arrow head is
%   decided by the minimum distance between start and stop.
%   
%   
%   Bug Fixed:
%   1. arrow3d([ 0 0 -1 ], [ 0 0 -2]) points the wrong way 
%      Found by Pavel Grinfeld(pg@math.drexel.edu)
%      Fixed By: WaitingForMe 2006/7/24
% 
%   The functin will return the handles of arrow bodies and arrow heads   
%
%   Usage:
%       [hline,hhead]=arrow3d(start,stop)
%       [hline,hhead]=arrow3d(start,stop,ang)
%       [hline,hhead]=arrow3d(start,stop,ang,linetype)
%       [hline,hhead]=arrow3d(start,stop,ang,linetype,p)
%       [hline,hhead]=arrow3d(start,stop,ang,linetype,p,n)
% 
%   Start:      The starting points.
%   Stop :      The end points.
%   Ang  :      The arrow head angle
%   linetype:   Choose the body type, you can set this to be 'line' or 
%               'cylinder', 'cylinder' is the default value
%   p    :      P(1) is the ratio of arrow head height to the distance
%               between start and stop points
%               P(2) is the ratio of arrow body
%   n    :      The arrow head has n(1) equally spaced points around its circumference.
%               The arrow body has n(2) equally spaced points around its circumference.
%
%   Example:
%       t=linspace(0,4*pi,40);
%       x=cos(t);y=sin(t);z=0.2*t;
%       p=[x' y' z'];
%       p1=p(1:end-1,:);p2=p(2:end,:);
%       arrow3d(p1,p2,15,'cylinder',[0.5,0.5]);axis equal;grid on;
% 
%   Author: Changshun Deng
%   Email: heroaq_2002@163.com
%   WEB-Log: http://waitingforme.yculblog.com
%   30/8/2005 


%Check start and stop point data
%the column number must be 3, and the row number must greater than 0
%Set default data
if nargin<3 ang=30; end
if nargin<4 ltype='cylinder'; end
if nargin<5 p=[0.25,0.1]; end
if nargin<6 n=[20,10]; end
if size(start,1)<1 | size(stop,1)<1
    error([upper(mfilename) ': start point data or stop piont data must be a m*3 matrix']);
end
if size(start,2)~=3 | size(stop,2)~=3
    error([upper(mfilename) ': start point data or stop piont data must be a m*3 matrix']);
end
%p(1) is the ratio of arrow head height to the distance between start and end points
%p(2) is the ratio of cylinder radial to arrow head height
%Check if p is between 0 and 1
if ~all(p<=1 & p>0)
    error([upper(mfilename) ': p must between 0 and 1']);
end
%n(1) is the patch number of arrow head
%n(2) is the patch number of cylinder
%Check if n a positive integer, and n must greater than 2
n=ceil(n);
if ~all(n>2)
    error([mfilename ': patch number of arrow head and cylinder must greater than 3']);
end
%Calculate the direction vectors between start and end points
dvec=stop-start;
%Calculate the distances between start and end points
dis=sqrt(sum(dvec.^2,2));
%The height of arrow head
hv=min(dis)*p(1);
%Generate the initial line data of 3d arrows
init_start=zeros(size(start));
init_stop=[zeros(size(dis)) zeros(size(dis)) (dis-hv).*ones(size(dis))];
%Calculate Rotate angles of the lines
cosrang=acos(dvec(:,3)./dis)*180/pi;
%Calculate normal vector between arrow line and Z-axis
nvec=[-dvec(:,2) dvec(:,1) zeros(size(dis))];
%draw lines of arrows
if ~ishold
    hold on;
    view(3);
    SET_HOLD_OFF=true;
else
    SET_HOLD_OFF=false;
end
hlines=[];
if strcmp(ltype,'line')
    for i=1:length(dis)
        %Rotate end point
        [rx,ry,rz]=rotatedata(init_stop(i,1),init_stop(i,2),init_stop(i,3),nvec(i,:),cosrang(i),[0,0,0]);
        hlines(i)=line([start(i,1);start(i,1)+rx],[start(i,2);start(i,2)+ry],[start(i,3);start(i,3)+rz]);
    end
    hlgrd=[];
else
    for i=1:length(dis)
        r=hv*tan(ang./180.*pi).*p(2);
        [xi,yi,zi] = cylinder(r.*[1,1],n(2));
        zi=zi.*(dis(i)-hv);
        %escape the error if the arrow is in z-direction
        %if the arrow is in z-direction then the nvector result zeros to
        %make a error!
        %Fix this bug! 2006/07/24
        %Thanks to Pavel Grinfeld(pg@math.drexel.edu)
        if all(nvec(i,:)==0)
            nvec(i,:)=[0,1,0];
        end
        [rx,ry,rz] = rotatedata(xi,yi,zi,nvec(i,:),cosrang(i),[0,0,0]);
        cx=start(i,1)+rx;cy=start(i,2)+ry;cz=start(i,3)+rz;
        hlines(i)=surf(cx,cy,cz,'edgecolor','none','facecolor',[145,90,7]/255);
        hlgrd(i)=patch(cx(1,:),cy(1,:),cz(1,:),[145,90,7]/255);
    end
end
%Generate the initial arrow head data of 3d arrwos
hheads=[];
hgrd=[];
pv=dis-hv;
%draw heads of arrows
% for i=1:length(dis)
%     %Generate initial taper data
%     [xi,yi,zi] = cylinder([tan(ang/180*pi),0],n(1));
%     xi=xi*hv;yi=yi*hv;zi=zi*hv+pv(i);
%     %Rotate the taper
%     [rx,ry,rz] = rotatedata(xi,yi,zi,nvec(i,:),cosrang(i),[0,0,0]);
%     cx=start(i,1)+rx;cy=start(i,2)+ry;cz=start(i,3)+rz;
%     hheads(i)=surf(cx,cy,cz,'edgecolor','none','facecolor',[11 131 222]/255);
%     %Draw the underside of taper
%     hhgrd(i)=patch(cx(1,:),cy(1,:),cz(1,:),[7 86 145]/255);
% end
if SET_HOLD_OFF
    hold off;
end
if nargout>1 varargout{2}=[hheads;hhgrd]; end
if nargout>0 varargout{1}=[hlines;hlgrd]; end


function [newx,newy,newz]=rotatedata(xdata,ydata,zdata,azel,alpha,origin)
% 
% ROTATEDATA rotate data about specified origin and direction.
% 
%   ROTATEDATA(Xdata,Ydata,Zdata,[THETA PHI],ALPHA,ORIGIN) rotates the objects with handles H
%   through angle ALPHA about an axis described by the 2-element
%   direction vector [THETA PHI] (spherical coordinates).  
%   All the angles are in degrees.  The handles in H must be children
%   of the same axes.
%
%   THETA is the angle in the xy plane counterclockwise from the
%   positive x axis.  PHI is the elevation of the direction vector
%   from the xy plane (see also SPH2CART).  Positive ALPHA is defined
%   as the righthand-rule angle about the direction vector as it
%   extends from the origin.
%
%   ROTATEDATA(Xdata,Ydata,Zdata,[X Y Z],ALPHA,ORIGIN) rotates the objects about the direction
%   vector [X Y Z] (Cartesian coordinates). The direction vector
%   is the vector from the center of the plot box to (X,Y,Z).
%
%   See also SPH2CART, CART2SPH.
%
%   Modified by ChangShun Deng
%   Email: heroaq_2002@163.com
%   Web-Log: http://waitingforme.yculblog.com
%   2005/3/4
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.17 $  $Date: 2002/06/05 20:05:16 $

%判断输入变量的个数
if nargin<6
    error('Not enough input arguments! Type ''help rotatedata'' to get some help!')
end
%找到旋转的单位轴向量
if prod(size(azel)) == 2 % theta, phi
    theta = pi*azel(1)/180;
    phi = pi*azel(2)/180;
    u = [cos(phi)*cos(theta); cos(phi)*sin(theta); sin(phi)];
elseif prod(size(azel)) == 3 % direction vector
    u = azel(:)/norm(azel);
end

alph = alpha*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = u(1);
y = u(2);
z = u(3);
%旋转矩阵
rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
        x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
        x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';
[m,n] = size(xdata);
if isempty(z)
    z=zeros(size(x));%在对二维数据进行旋转时，z参数输入可以是空矩阵
end
newxyz = [xdata(:)-origin(1), ydata(:)-origin(2), zdata(:)-origin(3)];
newxyz = newxyz*rot;
newx = origin(1) + reshape(newxyz(:,1),m,n);
newy = origin(2) + reshape(newxyz(:,2),m,n);
newz = origin(3) + reshape(newxyz(:,3),m,n);