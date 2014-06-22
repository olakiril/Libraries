function SEF = computeSEF(day,varargin)

% function computeSEF(day)
%
% computes the spectral edge frequency or SEF
%
% MF 2009/09/09

params.percent = 0.75; %percent of the total power of a given signal are located
params.site = 0;

params = getParams(params,varargin);

global dataCon
sessMan = getContext(dataCon,'Session');

if ~params.site
    cells = getCells(day);
    sites = zeros(size(cells));
    for i = 1:length(cells)
        sites(i) = getParent(sessMan,cells(i));
    end
    sites = unique(sites);
else
    sites = day;
end

neuropil = filterElementByType(sessMan,'Neuropil',sites);

% neuropil(14) =[];

opticalTrace = getData(dataCon,neuropil,'DeltaFOF');
dfof = getData(dataCon,neuropil,'CalciumEventDetection');

sef = zeros(size(neuropil));
for i = 1:length(neuropil)
%     traceInf = getContent(opticalTrace(i));
    fps = getSamplingRate(opticalTrace(i));
%     trace = traceInf.trace;
%     trace = getTrace(opticalTrace(i));
trace = getIndex(dfof(i),'cDFoF');
    
    % fix for now sites that have nan values
    if sum(isnan(trace))>0
        sef = sef(1:end-1);
        continue
    end
    
    [y f] = fftPlot(trace,fps);
    x = cumsum(abs(y));
    sef(i) = f(find(x / max(x) > params.percent, 1));
end

SEF = median(sef);

if ~nargout>=1
    figure
    hist(sef);
    xlabel(['spectral edge frequency  %power below: ' num2str(params.percent*100)]);
    ylabel('# sites');
end
