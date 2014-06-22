function rftimecompare

rf_opts = [10;11;9;6];

params.stim_frames=15;
params.dot_size=120;
params.stim_idx = 1;

scanfits = fetch(Scans.*RFMap(params));

for key = scanfits'
    clf
    for iopt = 1:size(rf_opts,1)
        
        key.mask_type = 'cells';
        cells = CircCells(key);
        key.mask_type = 'site';
        site = CircCells(key);
        
        key.rf_opt_num = rf_opts(iopt);
        key.stim_frames=params.stim_frames;
        key.dot_size=params.dot_size;
        key.stim_idx = params.stim_idx;
        
        onpoffcells =  fetch1(RFMap(key).*cells,'onpoff_rf');
        [snrcells gauscells] = fetch1(RFFit(key).*cells,'snr','gauss_fit');
        snrcells = round(snrcells*100)/100;
        onpoffsite =  fetch1(RFMap(key).*site,'onpoff_rf');
        [snrsite gaussite] = fetch1(RFFit(key).*site,'snr','gauss_fit');
        snrsite = round(snrsite*100)/100;
        ftime = fetch1(RFOpts(key),'fraction_of_data');
        secs = ftime*5*60;
        
        h = subplot(2,size(rf_opts,1),iopt);
        imagesc(onpoffcells)
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        axis(h,'image')
        title(['snr:' num2str(snrcells)])
        if iopt == 1
            ylabel('cells')
        end
        hold on
        plotg(gauscells)
        
        h = subplot(2,size(rf_opts,1),iopt+size(rf_opts,1));
        imagesc(onpoffsite)
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        axis(h,'image')
        title(['snr:' num2str(snrsite)])
        if iopt == 1
            ylabel('site')
        end
        xlabel(num2str(secs))
        hold on
        plotg(gaussite)
        colormap gray
    end
    pause
end


function plotg(a)
m=a(1:2); C=diag(a(3:4)); cc=a(5)*sqrt(prod(a(3:4))); C(1,2)=cc; C(2,1)=cc;
plotGauss(m,C,2);