function spheresAt(x,y,z,R)
    if ~isvector(x) || ~isvector(y) || ~isvector(z) || ~isvector(R) || length(x) ~= length(y) || length(x) ~= length(z) || (length(R) > 1 & length(x) ~= length(R))
      error('all inputs must be scalar or vector and compatible sizes')
    end
    if length(R) == 1
      R = repmat(R, length(x), 1);
    end
    NumSphFaces = 100;
    [SX,SY,SZ] = sphere(NumSphFaces);
    washeld = ishold();
    hold on;
    for K = 1 : length(x)
      surf(SX*R(K) + x(K), SY*R(K) + y(K), SZ*R(K) + z(K),'edgecolor','none','markerfacecolor',[0.5 0.5 0.5]);
    end
    
    shading interp
    hold on
    axis equal
    camlight
%     lighting phong

    if ~washeld
      hold off
    end