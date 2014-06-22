function plotContrastResponse(days,contrasts,varargin)

% function plotContrastResponse(days,contrasts,varargin)
%
% plots the population contrast responses
%
% MF 2009-04-30

params.CorrelationType = 'RevCorrStats';
params.Thr = 0.05;
params.luminance = 0;
params.contrast = 0;
params.dprime = 1;
params.pi = 0;
params.collapse =1;
params.Bin = 8;
params.error = 1;
params.normalize = 1;
params.sigcell = 1;
params.sites  = 0;
params.DFoF = 0;
params.scatter = 1;
params.spatialFreq = 0;

params = getParams(params,varargin);

contrasts = sort(contrasts,'descend');

ConCorr = conCorr(days,contrasts,params);

DFoFS = ConCorr.DFoFS ;
uOriS = ConCorr.uOri ;
pOriS = ConCorr.pOri ;
PoS = ConCorr.Poo ;
% PdS = ConCorr.Pdd ;
% StdS = ConCorr.DFoFBinStd ;
SdeS = ConCorr.DFoFBinSde ;

prefDifference = bsxfun(@minus,(0:45:315)/360*2*pi,PoS{1}');
prefDiffOrientation = mod(prefDifference+pi/2,pi)-pi/2;
indx = prefDiffOrientation(:);

colors =hsv(size(contrasts,2));

if params.error
    Std = SdeS;
end


%% OUTPUT

if params.Bin
    if params.collapse
        v = min(indx):(abs(min(indx))+max(indx))/(params.Bin-1):max(indx);
        figure

        for i = 1:length(contrasts)
            DF = reshape(DFoFS{i},[1 params.Bin*size(uOriS,2)]);
            Er = reshape(SdeS{i},[1 params.Bin*size(uOriS,2)]);

            df = zeros(1,params.Bin-1);
            er = zeros(1,params.Bin-1);

            for j = 1:params.Bin-1
                df(j) = mean(DF(indx>=v(j)&indx<v(j+1)));
                er(j) = mean(Er(indx>v(j)&indx<v(j+1)));
            end

            df(params.Bin) = mean(DF(indx>=v(params.Bin)));
            er(params.Bin) = mean(Er(indx>=v(params.Bin)));

            errorbar(v*180/pi,df,er,'color',colors(i,:));

            if i == 1
                AxisPro = axis;
                Yscale = AxisPro(4)-AxisPro(3);
            end

            text(40,(AxisPro(3)+(Yscale*(12-i))/12),['Contrast % : '  num2str((contrasts(i))*100)],'color',colors(i,:));
            hold on
        end

        formatSubplot(gca,'box','off','ax','square', ...
            'xl','Angle difference','yl','Activity');

    else

        figure
        for i = 1:8
            subplot(4,2,i);
            for j = 1:size(unique(contrasts),2)
                a = DFoFS{j}(:,i);
                b =  (PoS{j});
                errorbar(b*180/pi,a,Std{j}(:,i),'color',colors(j,:));
                hold on
                title(num2str(uOriS(i)));
            end
            line(mod([uOriS(i) uOriS(i)],180), [0 0.5],'color',[.5 .5 .5])

            formatSubplot(gca,'box','off','ax','square','lim',[0 180 0 1], ...
                'xl','Orientation','yl','Activity')

        end

    end

else
    if params.collapse

        a = cell(1,size(DFoFS{1},2));
        b = cell(1,size(DFoFS{1},2));

        for i = 1:size(DFoFS{1},2)
            a{i} = DFoFS{1}(:,i)';
            b{i} =PoS{1}-pOriS(i);
        end
        A = cell2mat(a);
        B = cell2mat(b);

        [bb c]=sort(B);
        aa = A(c);
        p = polyfit(bb,aa,5);
        f = polyval(p,bb);
        figure

        if params.scatter
            plot(bb,aa,'r.')
            hold on
        end

        plot(bb,f,'r-')
        hold on

        a = cell(1,size(DFoFS{2},2));
        b = cell(1,size(DFoFS{2},2));

        for i = 1:size(DFoFS{2},2)
            a{i} = DFoFS{2}(:,i)';
            b{i} =PoS{2}-pOriS(i);
        end
        A = cell2mat(a);
        B = cell2mat(b);

        [bb c]=sort(B);
        aa = A(c);
        p = polyfit(bb,aa,5);
        f = polyval(p,bb);

        if params.scatter
            plot(bb,aa,'b.')
            hold on
        end

        plot(bb,f,'b-')

    else

        figure

        for i = 1:size(DFoFS{1},2)
            a = DFoFS{1}(:,i)';
            b =PoS{2};
            [b c]=sort(b);
            a = a(c);
            p = polyfit(b,a,5);
            f = polyval(p,b);


            aa = DFoFS{2}(:,i)';
            bb =PoS{2};

            [bb c]=sort(bb);
            aa = aa(c);
            pa = polyfit(bb,aa,5);
            fa = polyval(pa,bb);

            subplot(4,2,i)
            if params.scatter
                plot(bb,aa,'b.')
                hold on
                plot(b,a,'r.')
                hold on
            end

            plot(bb,fa,'b-')
            hold on
            plot(b,f,'r-')
            % line(mod([uOriS(i) uOriS(i)],180), [0 0.5],'color',[.5 .5 .5])

        end
    end
end

