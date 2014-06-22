function [SDm, Sdti, SOtiMin, SOtiMax] = circOri(uOri,Pdm,varargin)

% function [SDm Sdti SOtiMin SOtiMax] = circOri(uOri,Pdm)
%
% finds index for orientations 90 and 180 degrees away
%
% MF 2009-08-05

params.raw = 0;

params = getParams(params,varargin);

if params.raw
    circ_Dir = [(uOri/180)*pi 2*pi];
else
    circ_Dir = 1:length(uOri)+1;
end

SDm = find((abs(Pdm - circ_Dir) == min(abs(Pdm - circ_Dir))));

% if it is close to 360
if SDm > length(uOri)
    SDm = 1;
end

SDmC = SDm+length(uOri);

ori = 1:length(uOri);
oriCycle = [ori ori ori];

SOtiMin = oriCycle(SDmC-round(length(uOri)/4));
SOtiMax = oriCycle(SDmC+round(length(uOri)/4));
Sdti = oriCycle(SDmC+round(length(uOri)/2));


