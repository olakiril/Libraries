function customTraces(file,numberofcells,numberofpixels)

% file : the date and scan # (eg 100817_001)

tp = tpReader([file 'p%u.h5']);
im = getImagingChannel(tp,1);
data = getData(im);
imagesc(mean(data,3));
dfof = NaN(1,numberofcells);
for i = 1:numberofcells
    display(['Select ' num2str(numberofpixels) ' pixels for cell ' ...
        num2str(i) '/' num2str(numberofcells)]) 
    [x y] = ginput(numberofpixels);
    x = round(x);
    y = round(y);
    d = data(x,y,:);
    d = mean(d,1);
    d = mean(d,2);
    d = squeeze(d);

    % calc DF/F
    dfof(i) = (d - mean(d))/ mean(d);
    
end

figure;
plot(dfof);