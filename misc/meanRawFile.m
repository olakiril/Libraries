function meanRawFile(path)

path = getLocalPath([path 'p%u.h5']);
assert( exist(sprintf(path,0),'file')==2, 'File not found');
tpr = tpReader(path);
imageCh = getData(tpr.imCh{1});
meanImCh = mean(imageCh,3);

figure

subplot(121)
imagesc(meanImCh);
colormap gray
title ('Green Channel')

imageCh = getData(tpr.imCh{2});
meanImCh = mean(imageCh,3);

subplot(122)
imagesc(meanImCh);
title ('Red Channel')

    