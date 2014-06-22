function [PrOri Sign] = siteDir(days,contrasts,varargin)

% function [PrOri Sign] = siteDir(days,contrasts,varargin)
%
% MF 2009-04-25

params.CorrelationType = 'ForwardCorrelation';
params.Thr = 0.05;
params.luminance = 0;
params.contrast = 0;
params.dprime = 1;
params.sigcell = 1;
params.sites = 0;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

global dataCon;
sessMan = getContext(dataCon,'Session');

if params.dprime
    params.Poti = 'Pdoti';
    params.Pdti = 'Pddti';
else
    params.Poti = 'Poti';
    params.Pdti = 'Pdti';
end

if params.sites
    sites = days;
else
    Sites = cell(1,size(days,1));
    for l = 1: size(days,1)
        site = days(l,:);
        Sites{l} = filterElementByMeta(sessMan,'Site','mouseId',site);
    end
    sites = cell2mat(Sites);
end

PrOri = zeros(1,length(sites));
Sign = zeros(1,length(sites));

for l = 1:length(sites)
    fc = cell(1,length(contrasts));
    fsize = zeros(1,length(contrasts));
      
    cells = filterElementByType(sessMan,'Cell',sites(l));
    contrasts = sort(contrasts,'descend');

    for i = 1:length(contrasts)
        fc{i} = getData(dataCon,cells,params.CorrelationType,'ThrContrast',contrasts(i));
        fsize(i) = size(fc{i},2);
    end

    if var(fsize)
        error ('differend number of cells for each contrast');
    end
    
    Indx = cell(1,length(fc{1}));

    for i = 1:length(fc{1})

        oti = getPoti(fc{1},i);

        if isempty(oti)
            Indx{i}  = 1;
        end

        if params.sigcell
            if oti >params.Thr
                Indx{i}  = 1;
            end
        end
    end

    indx = find(cell2mat(Indx));
    ori = cell(1,length(fc));
    dir = cell(1,length(fc));
    Po  = cell(1,length(fc));
    Pd  = cell(1,length(fc));
    
    for i = 1:length(fc)

        ori{i} = getVonMises(fc{i},2,indx);
        dir{i} = getVonMises(fc{i},1,indx);
        Po{i}  = getVonMises(fc{i},3,indx);
        Pd{i}  = getVonMises(fc{i},4,indx);

    end

    PrOri(l) = circ_mean(Po{1}*2)/2;
    Sign(l) = circ_rtest(Po{1}*2);

end


