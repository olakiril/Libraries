function plotRFMapsComp(varargin)

params.print = 0;

params = getParams(params,varargin);

printout = params.print;
params = rmfield(params,'print');

keys = fetch((Traces('trace_opt = 2').*RFStats(params)));

for key = keys'
    clusters = {};
    [clusters(:,1) clusters(:,2) clusters(:,3) clusters(:,4)] =  fetchn(RFMap(key,'rf_opt_num<6'),'on_rf','off_rf','onmoff_rf','onpoff_rf');

    if size(clusters,1)~=10
        continue
    end

    [snr a] = fetchn(RFFit(key,'rf_opt_num=6'),'snr','gauss_fit');
    p = fetchn(RFStats(key,'rf_opt_num = 6'),'onpoff_p');
    ynames = {'on','off','on - off','on + off'};
    onNames = fetchn(RFOpts(key,'rf_opt_num<6'),'time_on');
    offNames = fetchn(RFOpts(key,'rf_opt_num<6'),'time_off');
    [dotSizes stimFrames] = fetchn(RFStats(key,'rf_opt_num=6'),'dot_size','stim_frames');
    h = [];

    for iExp = 1:2
        figure(iExp)
        clf
        indx = [1 5;6 10];
        dotSize = dotSizes(iExp);
        stimFrame = stimFrames(iExp);

        cluster = clusters(indx(iExp,1):indx(iExp,2),:);
        for iTimes = 1:size(cluster,1)
            dataTypes = cluster(iTimes,:);
            for iTypes = 1:size(cluster,2)
                iTypesV = 0:size(cluster,1):(size(cluster,2)-1)*size(cluster,1);

                h(iTimes,iTypes) = subplot(4,5,iTimes+iTypesV(iTypes)); %#ok<AGROW>
                imagesc(dataTypes{iTypes});
                axis(h(iTimes,iTypes),'image')
                hold on
                m=a{iExp}(1:2); C=diag(a{iExp}(3:4)); cc=a{iExp}(5)*sqrt(prod(a{iExp}(3:4))); C(1,2)=cc; C(2,1)=cc;
                plotGauss(m,C,2);
                set(gca,'XTick',[])
                set(gca,'YTick',[])
                colormap gray
                if iTimes == 1;ylabel(gca,ynames{iTypes});end
                if iTypes == size(cluster,2);xlabel(gca,[num2str(onNames(iTimes)) ':' num2str(offNames(iTimes))]);end
            end
        end

        if size(cluster,2);for iTypes = 1:size(cluster,2);linkcaxes(h(:,iTypes));end;end

        key.dotSize = dotSizes';
        key.stimFrames = stimFrames';
        values = struct2cell(key);
        names = fieldnames(key);
        titl = ['stimFrames: ' num2str(stimFrame) ', dotSize: ' ...
            num2str( dotSize) ', snr: ' num2str(snr(iExp)) ',p: ' num2str(p(iExp))];
        identity = cell2mat(strcat(names,';',cellfun(@num2str,values,'UniformOutput',0),',')');
        set(gcf,'Name',identity)
        suplabel(titl,'t', [.08 .08 .84 .84]);
        suplabel('msec from onset','x',[.08 .08 .84 .84]);
        suplabel('method','y');
        print('-dpng',num2str(iExp))
    end

    % Import the file
    figure(3)
    clf
    set(gcf,'Color',[1 1 1])
    rawData1 = importdata('1.png');
    rawData2 = importdata('2.png');
    subplot(2,2,1)
    imagesc(rawData1)
    set(gca,'Box','Off')
    set(gca,'Xtick',[])
    set(gca,'XColor',[1 1 1])
    set(gca,'YColor',[1 1 1])
    subplot(2,2,2)
    imagesc(rawData2)
    set(gca,'Box','Off')
    set(gca,'Xtick',[])
    set(gca,'XColor',[1 1 1])
    set(gca,'YColor',[1 1 1])

    if printout
        set(gcf,'PaperSize',[8 3]) 
        set(gcf,'PaperPositionMode','manual');
        set(gcf,'PaperPosition',[-1.2 -3.8 10 7])
        print(gcf,'-dpdf',identity);
    elseif length(keys) ~= 1 || length(reps) ~= 1
        pause
    end
end
