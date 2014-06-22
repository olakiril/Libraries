function params = plotStatsOri(varargin)

% function plotSite, for StatsOriTracesObject
% plots the orientation properties of the cells on top of the site

params.thr = 0.05;
params.trace_opt = 6;
params.movie_type = 'natural';

params = getParams(params,varargin);

thr = params.thr;
params = rmfield(params,'thr');

keys = fetch(MaskGroup.*StatsOri(params));

for ikey = 1:length(keys)
    key = keys(ikey);
    key = catstruct(key,params);
    
    [dm p] = fetchn(StatsOriTraces(key).*Traces('masknum > 0'),'Pdm','Pdoti');
    
    if isempty(dm)
        display('No data for given input')
        continue
    end
    
    % set Colors
    s  = ( p < thr);
    h = cell2mat(dm)/pi;
    v = ones(length(p),1)*0.9;
    colors = hsv2rgb([h s v]);
    
    % set Possitions
    [cellx celly cellz] = fetchn(MaskCells.*MaskGroup(key),'img_x','img_y','img_z');
    subplot(3,4,[1 2 3 5 6 7 9 10 11])
    scatter3(cellx,celly,cellz - fetch1(Scans(key),'z - surfz -> depth'),100,'filled','CData',colors)
    
    % plot parameters
    
    xlabel('X (microns)')
    ylabel('Y (microns)')
    zlabel('Z (microns)')
    set(gcf,'Color',[1 1 1])
    colormap(hsv(180))
    cb = colorbar;
    pos = get(cb,'Position');
    pos(3) = pos(3)/4;
    pos(2) = pos(2)*1.2;
    pos(1) = pos(1)*1.3;
    pos(4) = pos(4)/2;
    set(cb,'Position',pos);
    tic = get(cb,'TickLength');
    set(cb,'TickLength',tic/100);
    set(cb,'Ytick',0:0.1:1);
    set(cb,'YTickLabel',(0:0.1:1)*180);
    set(cb,'Box','Off')
    title(['site:',num2str(key.scan_idx),', day:',num2str(key.exp_date),', % TC:',num2str(round(mean(p<thr)*100)/100)])
    subplot(3,4,4)
    hist((cell2mat(dm)/pi)*180);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[0.7 0.7 0.7],'EdgeColor','w')
    set(gca,'Box','Off')
    if length(keys)>1
        pause
    end
end