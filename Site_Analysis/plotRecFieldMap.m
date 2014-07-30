function plotRecFieldMap(site)

% function plotSiteMaps(site)
%
% plots the Rec fields of a site together with the orientation preference
% of each pixes for its receptive field
%
% MF 2009-08-08

global dataCon

fc = getData(dataCon,site,'MapRecFieldDim');
dc = getData(dataCon,site,'RecFieldOriComp');

% get data fc,dc
oriPre = getZscore(dc);
locPre = getZscore(fc);

% find prefered location
[maxpixel maxPos] = max(locPre,[],3);

% digitize orientation preference
maxOriPre = oriPre<0; % ones are horizontal preference

% intergrate
maxOri = reshape(maxOriPre,[],size(oriPre,3));
oriPreLoc = zeros(size(maxOri,1),1);
for k = 1: size(maxOri,1)
    oriPreLoc(k) = maxOri(k,maxPos(k));
end

oriPreLoc = reshape(oriPreLoc,size(maxPos));
plotMapRecFieldDim(fc);

subplot(2,2,4)
imagesc(oriPreLoc);
formatSubplot(gca,'ax','square');
set(gca,'xtick',[])
set(gca,'ytick',[])
title('Orientation preference: white-->horizontal, black--> vertical')
set(gcf,'Color',[1 1 1]);





