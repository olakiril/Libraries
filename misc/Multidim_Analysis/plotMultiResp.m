function plotMultiResp(days,varargin)

% function plotMultiResp(days,varargin)
%
% plots the response of all the sites to the different parameters of the
% multidimentional stimulus
%
% MF 2009-04-19

params.dir = 0;
params.mat = 0;
params.dprime = 0;
params.batch = 1;
params.contrasts = [0.10;0.50;0.95];
params.spatialFreqs = [0.04;0.08];
params.print = 0;

params = getParams(params,varargin);

pOtiMean = cell(size(params.spatialFreqs,1)*size(params.contrasts,1),1);
prcSign = cell(size(params.spatialFreqs,1)*size(params.contrasts,1),1);
daylength = cell(size(params.spatialFreqs,1)*size(params.contrasts,1),1);
paramAxes = zeros(size(params.spatialFreqs,1)*size(params.contrasts,1),2);
k = 0;

for i = 1:size(params.spatialFreqs,1)
    for j = 1:size(params.contrasts,1)
        k = k +1;
        [pOtiMean{k} prcSign{k} daylength{k}] = plotSiteSign(days,'spatialFreq',params.spatialFreqs(i), ...
            'contrast',params.contrasts(j),'dir',params.dir,'mat',params.mat, ...
            'dprime',params.dprime,'batch',params.batch);
        paramAxes(k,:) = [i j];
    end
end

oti = cell2mat(pOtiMean);
prc = cell2mat(prcSign);
dayLength = cumsum(daylength{1});

for i = 1:k
    SF(i,1:3) = 'SF:';
    C(i,1:3) = ' C:';
end

axesParams = ([SF num2str(params.spatialFreqs(paramAxes(:,1)))...
    C num2str(100*params.contrasts(paramAxes(:,2)))]);

for i = 1:length(dayLength)-1
    shifts(i,1:k+2) = dayLength(i)+0.5;
end

%% OUTPUT plot

figure

subplot(2,1,1)
imagesc(oti)
set(gca,'box','off');
set(gca,'xtick',[]);
set(gca,'YTick',1:k);
set(gca,'YTickLabel',axesParams);
ylabel(gca,'params');
colorbar
hold on
plot(shifts,(0:k+1),'-b','MarkerSize',200)
title('OTI of sites for different multidimentional params')


subplot(2,1,2)
imagesc(prc)
set(gca,'box','off');
set(gca,'YTick',1:k);
set(gca,'YTickLabel',axesParams);
xlabel(gca,'sites');
ylabel(gca,'params');
colorbar
hold on
plot(shifts,(0:k+1),'-b','MarkerSize',200)
title('% significance of sites for different multidimentional params')

colormap(gray)
set(gcf,'Color',[1 1 1])

set(gcf,'paperpositionmode','auto');
name = '/mnt/lab/users/Manolis/Matlab/batchOut/plot';

if params.print
    print ('-dpng',name)
end
    