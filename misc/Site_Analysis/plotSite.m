function [X Y]=plotSite(siteId,varargin)
% function plotSite(site,varargin)
%
%  Visualize the activity of all the traces for a site
%
% Takes a site Object
%
% plotSite(site,dataCon)
%
% MF 2008-12-05

params.Thr = 0.05;
params.SiteCelling = 0;
params.Orientation = 0;
params.Direction = 0;
params.dprime = 0 ;
params.CorrelationType = 'RevCorrStats';
params.luminance = 0;
params.contrast = 0;
params.arrow = 0;
params.arrows = 0;
params.batch = 0;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end


% get the necessary information

global dataCon;

assert(length(site) == 1, 'Just use for one site only');

sessMan = getContext(dataCon,'Session');
% siteId = filterElementbyMeta(sessMan,'Site','mouseId',site);

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

% fit VonMises to each cell

fc = getData(dataCon,cells,params.CorrelationType);%'luminance',params.luminance,'ThrContrast',params.contrast);
dc = struct(fc);
DTI = [];
if params.dprime
    for i = 1:length(dc)
        if isempty(dc(i).FitVonMisses)
            maxOtis(i) = 0;
            maxDtis(i) = 0;
            maxRes(i) = 0;
            minRes(i) = 0;
            Po(i) = 0;
            Dm(i) = 0;
        else

            maxOtis(i) = dc(i).dPrimeOri;
            maxDtis(i) = dc(i).dPrimeDm;
            maxRes(i) = max(dc(i).AreaMatrixMean);
            minRes(i) = min(dc(i).AreaMatrixMean);
            Po(i) = dc(i).FitVonMisses(3);
            Dm(i) = dc(i).FitVonMisses(4);
        end


    end

    % Calculate the average span of the indexies
    maxOti = max(maxOtis);
    maxDti = max(maxDtis);
    clims = [prctile(minRes,10) prctile(maxRes,90)];


    imOti = im*0;
    imDti = im*0;
    imDm = im*0;
    imPo = im*0;
    q = 1;
    w = 1;

    % Exchange the cell values of the mask with the Oti or Dti

    for i = 1:length(dc)
        kl = find(id==dc(i).refId);
        k = maskNum(kl);

        if isempty(dc(i).FitVonMisses)
            imOti(find(im==k))= 0;
            imDti(find(im==k))= 0;
            imDm(find(im==k))= 0;
            imPo(find(im==k))= 0;
            OTIS(i) = 0;
        else

            imOti(find(im==k))= (dc(i).dPrimeOri/maxOti);
            imDti(find(im==k))= (dc(i).dPrimeDm/maxDti);
            imDm(find(im==k))= dc(i).FitVonMisses(4);
            imPo(find(im==k))= dc(i).FitVonMisses(3);
            OTIS(i) = dc(i).refId;
        end

        if dc(i).Poti<=params.Thr
            OTI(w) = dc(i).refId;
            w = w+1;
        end

        if dc(i).Pdti<=params.Thr
            DTI(q) = dc(i).refId;
            q = q+1;
        end
    end

else

    for i = 1:length(dc)
        if isempty(dc(i).FitVonMisses)
            maxOtis(i) = 0;
            maxDtis(i) = 0;
            maxRes(i) = 0;
            minRes(i) = 0;
            Po(i) = 0;
            Dm(i) = 0;
        else

            maxOtis(i) = dc(i).FitVonMisses(2);
            maxDtis(i) = dc(i).FitVonMisses(1);
            maxRes(i) = max(dc(i).AreaMatrixMean);
            minRes(i) = min(dc(i).AreaMatrixMean);
            Po(i) = dc(i).FitVonMisses(3);
            Dm(i) = dc(i).FitVonMisses(4);
        end


    end

    % Calculate the average span of the indexies
    maxOti = max(maxOtis);
    maxDti = max(maxDtis);
    clims = [prctile(minRes,10) prctile(maxRes,90)];


    imOti = im*0;
    imDti = im*0;
    imDm = im*0;
    imPo = im*0;
    q = 1;
    w = 1;

    % Exchange the cell values of the mask with the Oti or Dti

    for i = 1:length(dc)
        kl = find(id==dc(i).refId);
        k = maskNum(kl);

        if isempty(dc(i).FitVonMisses)
            imOti(find(im==k))= 0;
            imDti(find(im==k))= 0;
            imDm(find(im==k))= 0;
            imPo(find(im==k))= 0;
            OTIS(i) = 0;
        else

            imOti(find(im==k))= (dc(i).FitVonMisses(2)/maxOti);
            imDti(find(im==k))= (dc(i).FitVonMisses(1)/maxDti);
            imDm(find(im==k))= dc(i).FitVonMisses(4);
            imPo(find(im==k))= dc(i).FitVonMisses(3);
            OTIS(i) = dc(i).refId;
        end

        if dc(i).Poti<=0.05
            OTI(w) = dc(i).refId;
            w = w+1;
        end

        if dc(i).Pdti<=0.05
            DTI(q) = dc(i).refId;
            q = q+1;
        end
    end
end
% Some necessary stuff to get a stable B/W image of the site

y = ch1.image - min(min(ch1.image));
z = y/max(max(y))*255;
s = uint8(z);
ch1image(:,:,1)=s;
ch1image(:,:,2)=s;
ch1image(:,:,3)=s;

v = mean(ch1.image,3);
v = (v - min(min(v)))/(max(max(v))-min(min(v)));
imDms = imDm.*(360/(2*pi));
imPos = imPo.*(180/(pi));

%% Plot the stuff
if params.SiteCelling

    j=[];
    loop=[];
    close all;
    while (isempty(loop))

        figure

        s  = (imDti>0);
        h = (imDms./360);
        image(hsv2rgb(cat(3,h,cat(3,s,v))));
        colormap(hsv(360));
        colorbar;

        figure

        s  = (imOti>0);
        h = (imPos./180);
        image(hsv2rgb(cat(3,h,cat(3,s,v))));
        colormap(hsv(180));
        colorbar;


        j = ginput(2);
        l = 1;
        [x,y] = meshgrid(1:size(im,2),1:size(im,1));

        figure (1)

        for i = 2:length(maskNum)
            xPos = mean(x(im==maskNum(i)));
            yPos = mean(y(im==maskNum(i)));

            if isempty(find(DTI==id(i)))
                h = text(xPos,yPos,num2str(id(i)),'color','black','Fontsize',8);
            else
                h = text(xPos,yPos,num2str(id(i)),'color',[0 1 0],'Fontsize',8);
            end

            set(h,'HorizontalAlignment','Left');
            set(h,'VerticalAlignment','Top');
        end

        figure (2)

        for(i = 2:length(maskNum))
            xPos = mean(x(im==maskNum(i)));
            yPos = mean(y(im==maskNum(i)));

            if isempty(find(OTI==id(i)))
                h = text(xPos,yPos,num2str(id(i)),'color','black','Fontsize',8);
            else
                h = text(xPos,yPos,num2str(id(i)),'color',[0 1 0],'Fontsize',8);
            end

            set(h,'HorizontalAlignment','Left');
            set(h,'VerticalAlignment','Top');
        end

        figure

        s  = (imDti>0);
        h = (imDms./360);
        image(hsv2rgb(cat(3,h,cat(3,s,v))));
        colormap(hsv(360));
        colorbar;

        for(i = 2:length(maskNum))
            xPos = mean(x(im==maskNum(i)));
            yPos = mean(y(im==maskNum(i)));

            if ~isempty(find(OTIS==id(i)))
                if params.dprime
                    if dc(find(OTIS==id(i))).Pdoti<params.Thr
                        axx = [xPos; (xPos+(cos(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1))))]; % Calculate starting and ending point in X dimention of the arrow
                        axy = [(size(ch1image,1)-yPos);(size(ch1image,1)-yPos)+(sin(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1)))]; % Calculate starting and ending point in Y dimention of the arrow

                        [arrowx,arrowy] = dsxy2figxy(gca, axx, axy);

                        arrow = annotation('textarrow',arrowx,arrowy);
                        set(arrow,'HeadStyle','vback3','LineWidth',2)
                    end
                else

                    if dc(find(OTIS==id(i))).Poti<params.Thr
                        axx = [xPos; (xPos+(cos(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1))))]; % Calculate starting and ending point in X dimention of the arrow
                        axy = [(size(ch1image,1)-yPos);(size(ch1image,1)-yPos)+(sin(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1)))]; % Calculate starting and ending point in Y dimention of the arrow

                        [arrowx,arrowy] = dsxy2figxy(gca, axx, axy);

                        arrow = annotation('textarrow',arrowx,arrowy);
                        set(arrow,'HeadStyle','vback3','LineWidth',2)
                    end
                end
            end
        end

        for i = min(round(j(:,1))):max(round(j(:,1)))
            for k= min(round(j(:,2))):max(round(j(:,2)))
                h(l) = id(im(k,i));
                l = l+1;
            end
        end
        cell = unique(h);

        for i = 1:length(dc)
            if ~isempty(nonzeros(cell==dc(i).refId))
                figure
                VMPlot(fc(i),'clims',clims);
            end

        end

        pause
        loop = input('','s');
        close all;
    end
end

if params.Direction
%     figure

    s  = (imDti>0);
    h = (imDms./360);
    image(hsv2rgb(cat(3,h,cat(3,s,v))));
    colormap(hsv(360));
    colorbar;
%     set(gca,'FontSize',18)

    if params.arrows
        [x,y] = meshgrid(1:size(im,2),1:size(im,1));
        figure

        image(ch1image);

        for(i = 2:length(maskNum))
            xPos = mean(x(im==maskNum(i)));
            yPos = mean(y(im==maskNum(i)));

            if ~isempty(find(OTIS==id(i)))
                if params.dprime
                    if dc(find(OTIS==id(i))).Pddti<params.Thr

                        axx = [xPos; (xPos+(cos(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1))))];
                        axy = [(size(ch1image,1)-yPos);(size(ch1image,1)-yPos)+(sin(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1)))];

                        [arrowx,arrowy] = dsxy2figxy(gca, axx, axy);

                        arrow = annotation('textarrow',arrowx,arrowy);
                        set(arrow,'HeadStyle','vback3','LineWidth',2)
                        set(gca,'FontSize',18)

                    end
                else

                    if dc(find(OTIS==id(i))).Pdti<params.Thr

                        axx = [xPos; (xPos+(cos(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1))))];
                        axy = [(size(ch1image,1)-yPos);(size(ch1image,1)-yPos)+(sin(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1)))];

                        [arrowx,arrowy] = dsxy2figxy(gca, axx, axy);

                        arrow = annotation('textarrow',arrowx,arrowy);
                        set(arrow,'HeadStyle','vback3','LineWidth',2)
                        set(gca,'FontSize',18)

                    end
                end
            end
        end
    end
end

if params.arrow
    X = [];
    Y = [];
    for(i = 2:length(maskNum))

        if ~isempty(find(OTIS==id(i)))

            if dc(find(OTIS==id(i))).Pddti<params.Thr
                X = [X (cos(dc(find(OTIS==id(i))).FitVonMisses(4))*(dc(find(OTIS==id(i))).FitVonMisses(1)))];
                Y = [Y (sin(dc(find(OTIS==id(i))).FitVonMisses(4))*(dc(find(OTIS==id(i))).FitVonMisses(1)))];
            end
        end
    end
end

if params.Orientation

%     figure
    s  = (imOti);
    h = (imPos./180);
    image(hsv2rgb(cat(3,h,cat(3,s,v))));
    colormap(hsv(180));
    colorbar('location','southoutside');
    axis off

%     set(gca,'FontSize',18)


    [x,y] = meshgrid(1:size(im,2),1:size(im,1));

    %     figure
    %     image(ch1image);
    %
    %     for(i = 2:length(maskNum))
    %         xPos = mean(x(im==maskNum(i)));
    %         yPos = mean(y(im==maskNum(i)));
    %
    %         if ~isempty(find(OTIS==id(i)))
    %             if params.dprime
    %                 if dc(find(OTIS==id(i))).Pdoti<params.Thr
    %
    %                     axx = [xPos; (xPos+(cos(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1))))];
    %                     axy = [(size(ch1image,1)-yPos);(size(ch1image,1)-yPos)+(sin(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1)))];
    %
    %                     [arrowx,arrowy] = dsxy2figxy(gca, axx, axy);
    %
    %
    %                     line = annotation('line',arrowx,arrowy);
    %                     set(line,'LineWidth',2)
    %                 end
    %             else
    %
    %                 if dc(find(OTIS==id(i))).Poti<params.Thr
    %
    %                     axx = [xPos; (xPos+(cos(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1))))];
    %                     axy = [(size(ch1image,1)-yPos);(size(ch1image,1)-yPos)+(sin(dc(find(OTIS==id(i))).FitVonMisses(4))*(300*dc(find(OTIS==id(i))).FitVonMisses(1)))];
    %
    %                     [arrowx,arrowy] = dsxy2figxy(gca, axx, axy);
    %
    %
    %                     line = annotation('line',arrowx,arrowy);
    %                     set(line,'LineWidth',2)
    %                 end
    %             end
    %         end
    %     end

end

if max([params.SiteCelling params.Direction params.Orientation params.arrow])==0

    [x,y] = meshgrid(1:size(im,2),1:size(im,1));

    figure

    s  = (imDti>0);
    h = (imDms./360);
    image(hsv2rgb(cat(3,h,cat(3,s,v))));
    colormap(hsv(360));
    colorbar('location','southoutside');
    axis off

    for i = 2:length(maskNum)
        xPos = mean(x(im==maskNum(i)));
        yPos = mean(y(im==maskNum(i)));

        if ~isempty(OTIS==id(i))
            if dc(OTIS==id(i)).Poti<=params.Thr

                axx = [xPos; (xPos+(cos(dc(OTIS==id(i)).FitVonMisses(4))*(300*dc(OTIS==id(i)).FitVonMisses(1))))];
                axy = [(size(ch1image,1)-yPos);(size(ch1image,1)-yPos)+(sin(dc(OTIS==id(i)).FitVonMisses(4))*(300*dc(OTIS==id(i)).FitVonMisses(1)))];

                [arrowx,arrowy] = dsxy2figxy(gca, axx, axy);

                arrowx(arrowx<0) = 0;
                arrowx(arrowx>1) = 1;
                arrowy(arrowy<0) = 0;
                arrowy(arrowy>1) = 1;

                arrow = annotation('textarrow',arrowx,arrowy);
                set(arrow,'HeadStyle','vback3','LineWidth',2)
            end
        end
    end

end

if params.batch
    set(gcf,'Color',[1 1 1])

    day = findMetaData(sessMan,siteId,'mouseId');
    sites = filterElementByMeta(sessMan,'Site','mouseId',day);
    siteIndx = find(sites==siteId);


    name = [ day(1:6) 'Site' num2str(siteIndx)];

    print ('-dpng',name)

    close all
end
