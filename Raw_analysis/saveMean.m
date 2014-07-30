function saveMean(file)

tp = tpReader([num2str(file) 'p%u.h5']);
image = getData(tp.imCh{2});
meanIm = mean(image,3);
imagesc(meanIm);
colormap(gray)
print('-dpng ',num2str(file));
