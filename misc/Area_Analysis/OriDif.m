function [OriDifPo OriDifDm  CelDist CelPo CelDm] = OriDif(site,varargin)

% function [OriDifPo OriDifDm  CelDist CelPo CelDm] = OriDif(site,varargin)
%
%   OriDifPo is the difference of the preffered orientations between two
%   cells and OriDifDm the difference of preffered direction. CelDist gives
%   the distance of the comparing pairs. CelPo the preffered orientation
%   and CelDm the preffered direction.
%   Function takes as parameter a threshold of the significance of the
%   tuning (Thr)
%
% MF 2008-12-19

params.Thr = 0.05;
params.CorrelationType = 'ForwardCorrelation';
params.luminance = 0;
params.contrast = 0;
params.dprime = 1;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

global dataCon;

assert(length(site) == 1, 'Just use for one site only');

siteId = getId(site);
sessMan = getContext(dataCon,'Session');

neuropil = filterElementByType(sessMan,'Neuropil',siteId);
cells = filterElementByType(sessMan,'Cell',siteId);
neuroglia = filterElementByType(sessMan,'Neuroglia',siteId);
ids = [neuropil, cells, neuroglia];

mask =getData(dataCon,siteId,'Image','type','mask');
ch1 = struct(getData(dataCon,siteId,'Image','type','ch1'));

id = ids;


for(i = 1:length(ids))
    maskNum(i) = findMetaData(sessMan,id(i),'maskNum');
    label{i} = [num2str(maskNum(i)) ' (' num2str(id(i)) ')'];
end

im = getfield(getContent(mask),'image');

cells = filterElementByType(sessMan,'Cell',siteId);
fc = getData(dataCon,cells,params.CorrelationType,'luminance',params.luminance,'ThrContrast',params.contrast);
dc = struct(fc);


q = 1;
w = 1;

if params.dprime

        for i = 1:length(dc)
        k = find(id==dc(i).refId);
        if isempty(dc(i).FitVonMisses)

            OTIS(i) = 0;
        else


            OTIS(i) = dc(i).refId;
        end

        if dc(i).Pdoti<0.05
            OTI(w) = dc(i).refId;
            w = w+1;
        end

        if dc(i).Pddti<0.05
            DTI(q) = dc(i).refId;
            q = q+1;
        end
    end
else

    for i = 1:length(dc)
        k = find(id==dc(i).refId);
        if isempty(dc(i).FitVonMisses)

            OTIS(i) = 0;
        else


            OTIS(i) = dc(i).refId;
        end

        if dc(i).Poti<0.05
            OTI(w) = dc(i).refId;
            w = w+1;
        end

        if dc(i).Pdti<0.05
            DTI(q) = dc(i).refId;
            q = q+1;
        end
    end
end

%% Main Calculations

%   Calculate the preffered orientation and direction


[x,y] = meshgrid(1:size(im,2),1:size(im,1));
j = 1;
for(i = 2:length(maskNum))
    xPos = mean(x(im==maskNum(i)));
    yPos = mean(y(im==maskNum(i)));

    if ~isempty(find(OTIS==id(i)))
        if dc(find(OTIS==id(i))).Pdoti<params.Thr

            CelCoox(j) = xPos;
            CelCooy(j) = yPos;
            CelPo(j) = dc(find(OTIS==id(i))).FitVonMisses(3);
            CelDm(j) = dc(find(OTIS==id(i))).FitVonMisses(4);
            j = j +1;

        end
       
    end
end

%  Calculate the differense of orientations and directions

if ~sum(OTIS)==0 & j>2

    CelDist = [];
    OriDifPo = [];
    OriDifDm = [];

    for i = 1:length(CelCoox)

        CelDist =[CelDist sqrt((CelCoox(i+1:end)-CelCoox(i)).^2+(CelCooy(i+1:end)-CelCooy(i)).^2)];

        OrispacePo = CelPo(i)+[pi 0 -pi];
        OrispaceDm = CelDm(i)+[2*pi 0 -2*pi];


        OriDifPo = [OriDifPo min(abs(bsxfun(@minus,OrispacePo',CelPo(i+1:end))))];

        OriDifDm = [OriDifDm min(abs(bsxfun(@minus,OrispaceDm',CelDm(i+1:end))))];


    end


else

    CelDist = [];
    OriDifPo = [];
    OriDifDm = [];

end




