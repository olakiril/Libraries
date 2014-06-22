function ConCorr = conCorr(days,varargin)

% function ConCorr = conCorr(days,contrasts,varargin)
%
% MF 2009-04-25

params.CorrelationType = 'RevCorrStats';
params.Thr = 0.05;
params.luminance = 0;
params.dprime = 0;
params.pi = 0;
params.collapse =0;
params.Bin = 8;
params.normalize = 1;
params.sigcell = 1;
params.sites = 0;
params.DFoF = 0;
params.spatialFreq = 0;

params = getParams(params,varargin);

if params.dprime
    params.Poti = 'Pdoti';
    params.Pdti = 'Pddti';
else
    params.Poti = 'Poti';
    params.Pdti = 'Pdti';
end

uOri = [0 45 90 135 180 225 270 315];
pDri = (uOri/180)*pi;
pOri = [pDri(1:4) pDri(1:4)];

fc = getObjectData(days,params);
fsize = zeros(1,length(params.contrast));

for i = 1:length(fc)   
    fsize(i) = size(fc{i},2);
end

if var(fsize)
    error ('differend number of cells for each contrast');
end

Indx = zeros(1,length(fc{1}));

for i = 1:length(fc{1})
    oti = getPoti(fc{1},i);
    if isempty(oti)
        Indx(i)  = 1;
    end
    if params.sigcell
        if oti >params.Thr
            Indx(i)  = 1;
        end
    end
end

indx = find(Indx);

Poti = cell(1,length(fc));
Po = cell(1,length(fc));
Pd = cell(1,length(fc));
AreaMatrix = cell(1,length(fc));
DFoF = cell(1,length(fc));

for i = 1:length(fc)
    Poti{i} = getIndex(fc{i}, params.Poti,indx);
    Po{i} = getVonMises(fc{i},3,indx);
    Pd{i} = getVonMises(fc{i},4,indx);
    AreaMatrix{i} = getAreaMatrix(fc{i},'AreaMatrix',indx);
end

% get cell ids
ind = 1:length(fc{1});
ind(indx) = [];
cellId = getRefId(fc{1}(ind));

if params.DFoF
    for i = 1:length(fc)     
        VisOn = mean(AreaMatrix{i}(:,:,5:7),3);
        VisOff = mean(AreaMatrix{i}(:,:,end-1:end),3);
        DFoF{i}= (VisOn-VisOff)./VisOff;
    end
else
    for i = 1:length(fc)
        DFoF{i}= mean(AreaMatrix{i}(:,:,5:7),3);      
    end
end

if params.normalize
    DFmax = max(DFoF{1},[],2);
    for i = 1:length(fc)
        for j = 1: size(DFoF{i},1);
            DFoF{i}(j,:) = DFoF{i}(j,:)/DFmax(j);
        end
    end
end

Bin = pi/params.Bin;
PiBin = (0:Bin:pi);

PoBin = cell(1,length(PiBin)-1);
DFoFBin = cell(1,length(PiBin)-1);
PoBinMean = zeros(1,length(PiBin)-1);
DFoFBinMean = zeros(length(PiBin)-1,size(DFoF{1},2));
PdBin = cell(1,length(PiBin)-1);
PdBinMean = zeros(1,length(PiBin)-1);
DFoFBinStd = cell(1,length(fc));
Points = zeros(1,length(PiBin)-1);
DFoFBinSde = cell(1,length(fc));

for j = 1:length(fc)
    if params.Bin
        for i = 1:length(PiBin)-1
            PoBin{i} = Po{j}(Po{j}>=PiBin(i)&Po{j}<PiBin(i+1));
            DFoFBin{i} = DFoF{j}(Po{j}>=PiBin(i)&Po{j}<PiBin(i+1),:);
            PoBinMean(i) = mean(PoBin{i});
            DFoFBinMean(i,:) = mean(DFoFBin{i},1);
            PdBin{i} = Pd{j}(Po{j}>=PiBin(i)&Po{j}<PiBin(i+1));
            PdBinMean(i) = mean(PdBin{i});
            DFoFBinStd{j}(i,:) = std(DFoFBin{i},0,1);
            Points(i) = length(DFoFBin{i});
        end
        PoBin{length(PoBin)} = Po{j}(Po{j}>=PiBin(length(PoBin)));
        PoBinMean(length(PoBin)) = mean(PoBin{length(PoBin)});
        DFoFBin{length(PoBin)}= DFoF{j}(Po{j}>=PiBin(length(PoBin)),:);
        DFoFBinMean(length(PoBin),:) = mean(DFoFBin{length(PoBin)},1);
        PdBin{length(PoBin)} = Pd{j}(Po{j}>=PiBin(length(PoBin)));
        PdBinMean(length(PoBin)) = mean(PdBin{length(PoBin)});
        DFoFBinStd{j}(length(PoBin),:) = std(DFoFBin{length(PoBin)});
        Points(length(PoBin)) = length(DFoFBin{length(PoBin)});
        DFoFBinSde{j} = bsxfun(@rdivide,DFoFBinStd{j},(sqrt(Points))');

        DFoFS{j} = DFoFBinMean;
        Poo{j} = PoBinMean;
        Pdd{j} = PdBinMean;

    else
        DFoFBinStd = [];
        DFoFBinSde = [];
        DFoFS = DFoF;
        Poo = Po;
        Pdd = Pd;
    end
end

%% put everything into a structure

ConCorr.DFoFS = DFoFS;
ConCorr.uOri = uOri;
ConCorr.pOri = pOri;
ConCorr.Poo = Poo;
ConCorr.Pdd = Pdd;
ConCorr.DFoFBinStd = DFoFBinStd;
ConCorr.DFoFBinSde = DFoFBinSde;
ConCorr.CellId = cellId;
ConCorr.DFoF = DFoF;




