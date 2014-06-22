function [otiP dtiP PrOr DiMo] = poptun(days,varargin)

% [otiP dtiP PrOr DiMo] = function poptun(days,varargin)
%
% poptune provides statistical information about the significance of
% tunning for a population of cells.
%
% Outputs:
%   otiP : percentage of significantly orientationally tunned cells
%   dtiP : percentage of significantly directionally tunned cells
%   PrOr : Preferred Orientation across all cells
%   DiMo : Direction of Motion across all cells
%
% Inputs:
%   days takes the date information.
%   Example: days = ['081111_001';'081110_001'];
%
% Default Parameters & graphical outputs:
%   params.plot = [];                          : 1  for producing a histogram of the significance of tunning for all the cells
%   params.sitePlot = [];                      : 1  for plotting individually the sites
%   params.OrientationHistogram = [];          : 1  for Site information about distribution of selectvity
%   params.tunning = [];                       : 1  for Preferred orientation and direction for all the significantly tunned cells
%   params.response = [];                      : 1  for site responsiveness
%
%   params.Wiener = 0;                         : 1 for Correlation method with Wiener filter
%   params.Thr = 0;                            : Threshold of significance
%   params.luminance = 0;                      : Luminance threshold (zero for no threshold)
%   params.contrast = 0;                       : Contrast threshold (zero for 0.2)
%   params.sites = 0;                          : Select specific sites
%   params.dprime = 1;                         : 0 for tuning index
%
% MF 2009-01-24


params.plot = [];
params.sitePlot = [];
params.CorrelationType = 'ForwardCorrelation';
params.OrientationHistogram = [];
params.Thr = 0.05;
params.tunning = [];
params.luminance = 0;
params.contrast = 0;
params.response = 0;
params.sites = 0;
params.Wiener = 0;
params.dprime = 1;
params.allSites = 0;
params.duration = 0.5;


for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

if params.Wiener
    params.CorrelationType = 'ForwCorrWiener';
end

if params.dprime
    params.Poti = 'Pdoti';
    params.Pdti = 'Pddti';
else
    params.Poti = 'Poti';
    params.Pdti = 'Pdti';
end

global dataCon;
sessMan = getContext(dataCon,'Session');


sitess = [];
Poti = [];
Pdti =[];
RawData = [];
Po = [];
Dm = [];
VisResp = [];
RefId = [];
indx = [];

for l = 1: size(days,1)
    site = days(l,:);
    sites = filterElementByMeta(sessMan,'Site','mouseId',site);
    if params.sites
        sites = sites(params.sites);
    end
    sitess = [sitess sites];
    params.CorrelationType = findCorrelationType(sites(1));
    cells = filterElementByType(sessMan,'Cell',sites);
    fc = getData(dataCon,cells,params.CorrelationType); %,'luminance',params.luminance,'ThrContrast',params.contrast,'duration',params.duration);
    %     fcc = getData(dataCon,cells,'VisualResponse','luminance',params.luminance,'ThrContrast',params.contrast,'substractBaseline',params.subBase,'Wiener',params.Wiener);

    for i = 1:length(fc)
        oti = getPoti(fc,i);
        if isempty(oti)
            indx  = [indx i];
        end
    end

    poti = getIndex(fc, params.Poti,indx);
    Poti = [Poti poti];
    pdti = getIndex(fc,params.Pdti,indx);
    Pdti = [Pdti pdti];
%     rawData = getRawData(fc,indx);
%     RawData = [RawData rawData];
    po = getVonMises(fc,3,indx);
    Po = [Po po];
    dm = getVonMises(fc,4,indx);
    Dm = [ Dm dm];
    %     visResp = getIndex(fcc,'VisResp',indx);
    %     VisResp = [VisResp visResp];
    refId = getIndex(fc,'refId',indx);
    RefId = [RefId refId];


end

% for j = 1:length(RawData)
% 
%     RawDataS = RawData{j};
%     VisR = shiftdim(RawDataS,2);
%     VisR2 = reshape(VisR,size(RawDataS,1)*size(RawDataS,3),size(RawDataS,2));
% 
%     VisOn = mean( VisR2(:,4:8),2);
%     VisOff1 =  VisR2(:,end-1:end);
%     VisOff2 = mean(VisR2(:,1),2);
%     VisOff12 = [VisOff1 VisOff2];
%     VisOff =mean(VisOff12,2);
%     VisResp2(j) = signtest(VisOn,VisOff);
% 
% end
% 
% visResp = sum((VisResp2<params.Thr)/length(Poti));
otiP = (length(nonzeros(Poti<params.Thr)))/length(Poti);
dtiP = (length(nonzeros(Pdti<params.Thr)))/length(Pdti);

[NumO Oris] = hist(Po);
[NumD Dirs] = hist(Dm);
PrOr = Oris(NumO==max(NumO));
DiMo = Dirs(NumD==max(NumD));
DAY = [];

for i = 1:size(days,1)
    DAY = [DAY,' ',days(i,1:6)];
end
% Untune = sum((Poti>params.Thr).*(Pdti>params.Thr).*(VisResp2<params.Thr))/length(Poti);



%% Subfunctions of graphical outputs


if params.plot


    figure('Name',['Method: ',num2str(params.CorrelationType),', Days: ',num2str(DAY)],'NumberTitle','off');
    subplot(2,1,1)
    hist(Poti,20);
    title([num2str(params.Poti) ' % Orientation: ' num2str(otiP)]);
    subplot(2,1,2)
    hist(Pdti,20);
    title([num2str(params.Pdti) ' % Direction: ' num2str(dtiP)]);


end

if params.tunning
    figure('Name','Orientation and direction preference for all the sites','NumberTitle','off');
    subplot(2,1,1)
    hist(Po,100);
    title('Orientation' );
    subplot(2,1,2)
    hist(Dm,100);
    title('Direction');
end

if params.sitePlot
    figure('Name','Site info','NumberTitle','off');
    for i = 1: length(sites)
        AllCells = filterElementByType(sessMan,'Cell',sites(i));
        k = 1;
        Cells = [];
        for j = 1:length(RefId)
            if sum(RefId(j)==AllCells)~=0
                Cells(k) = AllCells(find(RefId(j)==AllCells));
                k = k+1;
            else
                continue
            end

        end

        NumCells(i) = length(Cells);
        PotiNew = Poti((sum(NumCells)+1)-NumCells(end):sum(NumCells));
        PdtiNew = Pdti((sum(NumCells)+1)-NumCells(end):sum(NumCells));
        [PotiSite X] = hist(PotiNew,20);
        [PdtiSite X] = hist(PdtiNew,20);
        PSite = [PotiSite; PdtiSite;];
        y = ceil(length(sites)/(length(sites)/2));
        subplot(y,ceil(length(sites)/2),i);

        bar3(X,PSite');
        title([num2str(params.Poti) ': ' num2str(round(((length(nonzeros(PotiNew<params.Thr)))/ NumCells(i))*100)) ' ' num2str(params.Poti) ' : ' num2str(round(((length(nonzeros(PdtiNew<params.Thr)))/ NumCells(i))*100))]);

    end
end


if params.OrientationHistogram

    SiteObj = getElementById(dataCon,sitess);

    close all;
    figure ('Name','Po');
    figure ('Name','Dm');
    figure ('Name','HistPo');
    figure ('Name','HistDm');
    sub = ceil(length(SiteObj)/4);

    for i = 1:length(SiteObj)

        [OriDifPo OriDifDm  CelDist OrihistPo OrihistDm] = OriDif(SiteObj(i),'Thr',params.Thr,'CorrelationType',params.CorrelationType,'luminance',params.luminance,'contrast',params.contrast,'dprime',params.dprime);

        figure(1);
        %              subplot(4,sub,i);
        plot(CelDist,OriDifPo,'.','MarkerSize',5);
        formatSubplot(gca,'ax','square', ...
            'xl','Distance','yl','Angle','FontSize',18);
        set(gca,'YTick',0:pi/8:pi/2-pi/8)
        set(gca,'YTickLabel',{'0','1/8 pi','1/4 pi','3/8 pi'})
        set(gca,'FontSize',18)

        figure(2);
        %              subplot(4,sub,i);
        plot(CelDist,OriDifDm,'.','MarkerSize',5);
        formatSubplot(gca,'ax','square', ...
            'xl','Distance','yl','Angle','FontSize',18);
        set(gca,'YTick',0:pi/4:pi-pi/4)
        set(gca,'YTickLabel',{'0','1/4 pi','1/2 pi','3/4 pi'})
        set(gca,'FontSize',18)

        figure(3);
        %             subplot(4,sub,i);
        hist(OrihistPo,20);
        formatSubplot(gca,'ax','square', ...
            'xl','Angle','yl','Cell #','lim',[1 5 0 18],'FontSize',18);
        set(gca,'XTick',1:4)
        set(gca,'XTickLabel',{'0','45','90','135'})
        set(gca,'FontSize',18)

        figure(4);
        %             subplot(4,sub,i);
        hist(OrihistDm,20);
        formatSubplot(gca,'ax','square', ...
            'xl','Angle','yl','Cell #','lim',[1 5 0 18],'FontSize',18);
        set(gca,'XTick',1:4)
        set(gca,'XTickLabel',{'0','90','180','270'})
        set(gca,'FontSize',18)

    end

end

if params.response

    Response = [visResp otiP dtiP];
    bar(Response*100,'r');
    formatSubplot(gca,'box','off','ax','square','lim',[1 3 0 100])
    ylabel(gca,'%','FontSize',18);
    set(gca,'FontSize',18)
    set(gca,'XTickLabel',{'Visual','Orientation','Direction'})
    set(gca,'FontSize',18)

end

if params.allSites

    SitePos = clusterFind(days,params);
    
    figure ('Name','Po');
    title(num2str(days(1:6)))
    densityDir(SitePos.CelDist,SitePos.OriDifPo);
    figure('Name','Dm');
    title(num2str(days(1:6)))
    densityDir(SitePos.CelDist,SitePos.OriDifDm,'cont',40);
end

