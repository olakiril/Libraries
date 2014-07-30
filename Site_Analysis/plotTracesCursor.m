function plotTracesCursor(key,cursorInfo)

% find site
if ~isfield(key,'exp_date')
    title = get(get(gca,'Title'),'String');
    sind = strfind(title,'site:');
    cind = strfind(title,',');
    key.scan_idx = str2double(title(sind + length('site:'): cind(1) - 1));
    sind = strfind(title,'day:');
    key.exp_date = title(sind + length('day:'): cind(2) - 1);
end

% replot figure
figure(1)
clf
plotStatsOri(key);
hold on

% get some data
depth = fetch1(Scans(key),'z - surfz -> depth');
[cellx celly cellz masknum] = fetchn(MaskCells.*MaskGroup(key),'img_x','img_y','img_z','masknum');

% loop through clicked cells and plot things
figure(2)
set(gcf,'Position',[1 1 940 740])
for iCell = 1:length(cursorInfo)
    
    [~, cellnum] = min(pdist2([cellx celly cellz-depth],...
        [cursorInfo(iCell).Position(1) cursorInfo(iCell).Position(2) cursorInfo(iCell).Position(3)]));   
    [x y z] = fetch1(MaskCells(['masknum = ' num2str(masknum(cellnum))]).*MaskGroup(key),'img_x','img_y','img_z');
    figure(1)
    subplot(3,4,[1 2 3 5 6 7 9 10 11])
    text(x,y,z - depth,num2str(masknum(cellnum)))
    figure(2);
    subplot(ceil(sqrt(length(cursorInfo))),ceil(sqrt(length(cursorInfo))),iCell)
    key.masknum = masknum(cellnum);
    plot(StatsOriTraces(key))
    key = rmfield(key,'masknum');
end