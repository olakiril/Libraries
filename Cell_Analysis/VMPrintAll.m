function VMPrintAll(day,varargin)

% function VMPlotAll(day,varargin)
%
%   VmPlotAll plots the data from forward correlation for each cell of a
%   site in sequence. Just hit enter for forward of a key and then Enter
%   for backwards
%
% MF 2008-12-01
% MF 2009-04-25

params.thr = 1;
params.text = 1;
params.CorrelationType = 'RevCorrStats';
params.clims = 1;
params.dprime = 0;
params.duration = 0;
params.site = 0;

params = getParams(params,varargin);
global dataCon;

% use dprime or oti
if params.dprime
    parPoti = 'Pdoti';
else
    parPoti = 'Poti';
end

% get Data
sessMan = getContext(dataCon,'Session');

if params.site
    cells = filterElementByType(sessMan,'Cell',sites);
else
    cells = getCells(day);
end

fc = getData(dataCon,cells,params.CorrelationType);
tunCel = getIndex(fc,parPoti);

% make the limits for all the cells the same
if params.clims
    areaMatrixMean = getAreaMatrixMean(fc);
    climsAv = zeros(length(fc),2);
    
    for i = 1:length(fc)
        climsAv(i,:) = [min(areaMatrixMean(i,:)) max(areaMatrixMean(i,:))];
    end

    params.clims = [prctile(climsAv(:,1),10) prctile(climsAv(:,2),90)];
end

% Loop through the cells and start ploting

for i = 1:length(fc)
    if tunCel(i)<params.thr
       close all
        VMPlot(fc(i),params);
        display([int2str(i) '/' int2str(length(fc))]);
        print('-dpng',[num2str(i)]);
       

    end
end


