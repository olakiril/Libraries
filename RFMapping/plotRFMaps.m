
function plotRFMaps(varargin)

import vis2p.*

% params.stim_frames=15;
% params.dot_size= 120;
params.trace_opt = 17;

params.supply = [];
params.print = 0;

params = getParams(params,varargin);

printout = params.print;
supply = params.supply;
params = rmfield(params,'print');
params = rmfield(params,'supply');

if isempty(supply)
    keys = fetch((Traces.*RFStats(params)));
else
    keys = fetch(supply);
end

for key = keys'

    reps = unique(fetchn(RFMap(key),'stim_idx'));
    key = catstruct(key,params);  %#ok<FXSET>

    for ireps = reps'
        cluster = {};
        key.stim_idx = ireps;
        [cluster(:,1), cluster(:,2), cluster(:,3), cluster(:,4)] =  fetchn(RFMap(key,'rf_opt_num<6'),'on_rf','off_rf','onmoff_rf','onpoff_rf');
        if isempty(cluster)
            continue
        end
        [snr, a, sframes, dotSz] = fetch1(RFFit(key,'rf_opt_num=3'),'snr','gauss_fit','stim_frames','dot_size');
        p = fetch1(RFStats(key,'rf_opt_num = 3'),'onpoff_p');
        ynames = {'on','off','on - off','on + off'};
        onNames = fetchn(RFOpts(key,'rf_opt_num<6'),'time_on');
        offNames = fetchn(RFOpts(key,'rf_opt_num<6'),'time_off');

        h = zeros(size(cluster));

        figure(ireps)
        clf
        for iTimes = 1:size(cluster,1)
            dataTypes = cluster(iTimes,:);
            for iTypes = 1:size(cluster,2)
                iTypesV = 0:size(cluster,1):(size(cluster,2)-1)*size(cluster,1);

                h(iTimes,iTypes) = subplot(4,5,iTimes+iTypesV(iTypes));
                imagesc(dataTypes{iTypes});
                axis(h(iTimes,iTypes),'image')
                hold on
                m=a(1:2); C=diag(a(3:4)); cc=a(5)*sqrt(prod(a(3:4))); C(1,2)=cc; C(2,1)=cc;
                plotGauss(m,C,2);
                set(gca,'XTick',[])
                set(gca,'YTick',[])
                colormap gray
                if iTimes == 1;ylabel(gca,ynames{iTypes});end
                if iTypes == size(cluster,2);xlabel(gca,[num2str(onNames(iTimes)) ':' num2str(offNames(iTimes))]);end
            end
        end

        if size(cluster,2);for iTypes = 1:size(cluster,2);linkcaxes(h(:,iTypes));end;end

        values = struct2cell(key);
        names = fieldnames(key);
        titl = ['stimFrames: ' num2str(sframes) ', dotSize: ' ...
            num2str( dotSz) ', snr: ' num2str(snr) ',p: ' num2str(p)];
        identity = cell2mat(strcat(names,';',cellfun(@num2str,values,'UniformOutput',0),',')');
        set(gcf,'Name',identity)
        suplabel(titl,'t', [.08 .08 .84 .84]);
        suplabel('msec from onset','x',[.08 .08 .84 .84]);
        suplabel('method','y');

        if printout
            set(gcf,'PaperOrientation','Landscape');
            set(gcf,'PaperType','A5');
            set(gcf,'PaperPositionMode','auto');
            print(gcf,'-dpdf',identity);
        elseif length(keys) ~= 1 || length(reps) ~= 1
            pause
        end
    end
end