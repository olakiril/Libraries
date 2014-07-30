function POnew = circShift(pO,varargin)

% function PO = circShift(pO)
%
% shifts preffered orientations some degrees
%
% MF 2009-05-05

params.shift = 90;
params.dir = 0;

params = getParams(params, varargin);

if params.direction
    params.shift = params.shift*2;
end

POnew = pO + params.shift*pi/180;

POnew(POnew>pi) = POnew(POnew>pi)-pi;
