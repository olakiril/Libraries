function  plotSitePref(days,varargin)

% function  plotSitePref(day,varargin)
%
% plots the responses of each site in a big matrix with histograms around
%
% MF 2009-04-12

params.CorrelationType = 'RevCorrStats';
params.Thr = 0.05;
params.spatialFreq = [];
params.contrast = [];
params.dprime = 0;
params.Bin = 8;
params.dir = 0;
params.batch = 0;
params.experiment = 0;
params.columns = 0;
params.depth = 0;
params.sites = 0;
params.neuropil = 0;
params.pca = 0;

params = getParams(params,varargin);

global dataCon;
sessMan = getContext(dataCon,'Session');

% use dprime or oti
if params.dprime
    parPoti = 'Pdoti';
    parPdti = 'Pddti';
else
    parPoti = 'Poti';
    parPdti = 'Pdti';
end

% do it for orientation or direction
if params.dir
    vonMissesIndex = 4;
    xlab = 'Binned Directions';
    type = 'D';
    params.pTi = parPdti;
    p = 2*pi;
else
    vonMissesIndex = 3;
    xlab = 'Binned Orientations';
    type = 'O';
    params.pTi = parPoti;
    p = pi;
end

Bin = p/params.Bin;
PiBin = (0:Bin:p);

if params.sites
    sites = days;
    dayShifts = zeros(size(sites));
else
    sitesDay = cell(1,size(days,1));
    dayShift = cell(1,size(days,1));
    for i = 1:size(days,1)
        sitesDay(i) = getObjectData(days(i,:),params,'output','sites');
        % detect rotating the screen
        if strcmp(days(i,:),'090406_001')
            dayShift{i} = ones(size(sitesDay{i}));
        else
            dayShift{i} = zeros(size(sitesDay{i}));
        end
    end
    dayShifts = cell2mat(dayShift);
    sites = cell2mat(sitesDay);
end
% get rid of sites without cells
siteIndx = zeros(1,length(sites));
for i = 1:length(sites);
    cells = filterElementByType(sessMan,'Cell',sites(i));
    siteIndx(i) = ~isempty(cells);
end
sites = sites(siteIndx==1);

ThrIndex = cell(1,length(sites));
PTi = cell(1,length(sites));
POri = cell(1,length(sites));
siteLength = zeros(1,length(sites));

% get data
for n = 1: length(sites)
    fc = getObjectData(sites(n),'input','site',params);
    indx = zeros(length(fc),1);
    % Find index for faulty cells
    for i = 1:length(fc)
        oti = getPoti(fc,i);
        if isempty(oti)
            indx(i) = i;
        end
    end
    indx = nonzeros(indx);
    pOriAll = getVonMises(fc,vonMissesIndex,indx);
    pTiAll = getIndex(fc, params.pTi,indx);
    ThrIndex{n} = pTiAll <= params.Thr;
    PTi{n} = pTiAll(ThrIndex{n});
    POri{n} = pOriAll(ThrIndex{n});
    siteLength(n) = length(PTi{n});
    % correct for rotating the screen
    if dayShifts(n)
        POri{n} = circOriShift(POri{n},params);
    end
end

yname = 'sites';
yvalues = 1:length(sites);
thrIndex = cell2mat(ThrIndex);
pTi = cell2mat(PTi);
pOri = cell2mat(POri);

% Calculate the percentage of significantly tunned cells
prcSign = length(pTi)/length(thrIndex);

% start calculating the relative matrix
siteIndex = zeros(size(pTi));
binIndex = cell(1,params.Bin);

for i = 1:length(siteLength)
    indexMatr = find(siteIndex==0,1,'first') ;
    siteIndex(indexMatr:indexMatr+siteLength(i)-1) = i;
end

if params.columns
    % Find all the sites that belong to the same vertical column
    x = zeros(1,length(sites));
    y = zeros(1,length(sites));
    column = zeros(1,length(sites));
    for i = 1:length(sites)
        x(i) = findMetaData(sessMan,sites(i),'x');
        y(i) = findMetaData(sessMan,sites(i),'y');
    end
    xy = x+y;
    [a b] = unique(xy);
    [c d] = sort(b);
    xyPos = a(d);

    for i = 1:length(sites)
        column(i) = find(xyPos==xy(i));
    end
    siteLength =  accumarray(column',siteLength')';
    sitestart = cumsum(siteLength)-siteLength+1;
    for i = 1:length(siteLength)
        siteIndex(sitestart(i):sitestart(i)+siteLength(i)-1) = i;
    end
    yname = 'Columns';
    yvalues = 1:length(siteLength);
end

if params.depth
    % bin cells according to their depth
    z = zeros(1,length(sites));
    siteBins = zeros(1,length(sites));
    for i = 1:length(sites)
        z(i) = findMetaData(sessMan,sites(i),'depth');
    end
    a = unique(z,'first');
    depthBin = min(a):(max(a)-min(a))/params.depth:max(a);
    newSiteLength = zeros(1,length(depthBin)-1);
    for i = 1:length(depthBin)-1
        siteBins(z>=depthBin(i) & z<=depthBin(i+1)) = i;
        newSiteLength(i) = sum(siteLength(z>=depthBin(i) & z<=depthBin(i+1)));
    end
    siteLength = newSiteLength;
    for i = 1:length(siteBins)
        siteIndex(siteIndex==i)=siteBins(i);
    end
    yname = 'Depth';
    yvalues = linspace(min(a),max(a),params.depth+1);
    yvalues = .5*(yvalues(1:end-1) +yvalues(2:end));
end

for i = 1:params.Bin
    binIndex{i} =  siteIndex(pOri>=PiBin(i)& pOri<PiBin(i+1));
end

matrix = zeros(max(siteIndex),params.Bin);
for i = 1:max(siteIndex)
    for j = 1:params.Bin
        matrix(i,j) = sum(binIndex{j}==i);
    end
    % normalize values
    matrix(i,:) = matrix(i,:)./sum(matrix(i,:));
end

% create even angle spaces
bcents = linspace(0,p,params.Bin+1);
bcents = .5*(bcents(1:end-1) + bcents(2:end));


%% OUTPUT Plot

figure(11)
figPos = get(gcf,'position');
close figure 11;
figure('position',[figPos(1) figPos(2)/2 figPos(4) figPos(4)*1.2])
set(gcf,'Color',[1 1 1])
subplot(4,3,[4:5 7:8 10:11])
imagesc(matrix);
colormap(gray)
set(gca,'YTick',1:length(siteLength))
set(gca,'YTickLabel',yvalues)
ylabel(gca,yname);
set(gca,'XTick',1:params.Bin)
set(gca,'XTickLabel',round(bcents/pi*(180)))
xlabel(gca,num2str(xlab));
matrixPosition = get(gca,'position');

subplot(4,3,1:2)
pos = get(gca,'position');
subplot('position',[matrixPosition(1) matrixPosition(4) ...
    + matrixPosition(2)+ 0.01 pos(3) pos(4)])
hist(pOri,bcents);
xlim([0 p])
set(gca,'xtick',[]);
ylabel(gca,'# cells');
set(gca,'box','off');

subplot(4,3,[6 9 12])
pos  = get(gca,'position');
subplot('position',[matrixPosition(1)+matrixPosition(4)-0.09 ...
    matrixPosition(2) pos(3)*1.2 pos(4)])
barh(fliplr(siteLength),1)
set(gca,'ytick',[]);
set(gca,'box','off');
xlabel(gca,'# cells');
ylim([0.5 length(siteLength)+ .5 ])

subplot(4,3,3)
axis off
AxisPro = axis;
Yscale = AxisPro(4)-AxisPro(3);

if size(days,1)>1
    days = 'multpl';
end

if ~params.sites; text(0,(AxisPro(3)+(Yscale*15)/12),'            Day  : ','FontWeight','Bold'); end
if ~params.sites; text(0,(AxisPro(3)+(Yscale*15)/12),['                       ' days(1:6) ]); end

text(0,(AxisPro(3)+(Yscale*12)/12),' %Sign.Tun : ','FontWeight','Bold');
text(0,(AxisPro(3)+(Yscale*12)/12),['                       ' num2str(round(prcSign*100)) '%']);

text(0,(AxisPro(3)+(Yscale*9)/12), 'Total#Cells :','FontWeight','Bold');
text(0,(AxisPro(3)+(Yscale*9)/12),[ '                       ' num2str(sum(siteLength)) ]);

if params.contrast; text(0,(AxisPro(3)+(Yscale*6)/12), '    Contrast :','FontWeight','Bold'); end
if params.contrast; text(0,(AxisPro(3)+(Yscale*6)/12),[ '                       ' num2str(params.contrast) ]);end

if params.spatialFreq; text(0,(AxisPro(3)+(Yscale*3)/12), '    Sp.Freq  :','FontWeight','Bold');end
if params.spatialFreq; text(0,(AxisPro(3)+(Yscale*3)/12),[ '                       ' num2str(params.spatialFreq) ]);end

set(gcf,'paperpositionmode','auto');


%% OUTPUT in batch mode
if params.batch

    name = ['/mnt/lab/users/Manolis/Matlab/batchOut/' days(1:6) 'C' num2str(round(params.contrast*10)) 'SF' ...
        num2str(params.spatialFreq*100) type];

    print ('-dpng',name)

    close all
end

