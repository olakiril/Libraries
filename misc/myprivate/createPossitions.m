function possitions = createPossitions(varargin)

% function a = createPossitions(varargin)
%
% creates multiple possitions for alexs' multidimentional stimulus
%
% DEFAULT params
% params.xMax = 700;
% params.yMax = 400;
% params.xPos = 5;
% params.yPos = 4;
%
% AE 2009-06-01
% MF 2009-07-10

params.xMax = 700;
params.yMax = 400;
params.xPos = 5;
params.yPos = 4;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

xStep = floor(2*params.xMax/(params.xPos - 1));
yStep = floor(2*params.yMax/(params.yPos - 1));

x = -params.xMax:xStep:params.xMax;
y = -params.yMax:yStep:params.yMax;
[X,Y] = meshgrid(x,y);
Z = [X(:), Y(:)]';
a = sprintf('%d,',Z(:));
possitions = a(1:end-1);

