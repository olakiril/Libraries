function pcaReview(file,eignum,prcframes)

if nargin<2
    eignum = 1;
    prcframes = 10;
elseif nargin<3
    prcframes = 10;
end

tpr = tpReader([file 'p%u.h5']);
chIm = getChannels(tpr);
imageChannel1  = getImagingChannel(tpr,chIm(1));
[x y z] = size(imageChannel1);
im = getData(imageChannel1);
immean = int16(mean(mean(im,2),1));
im = bsxfun(@minus,im,immean);
im = reshape(im,x*y,[]);
im = im(:, 1 : round(z * prcframes/100));
im = double(im);
[a b] = eigs(im' * im,eignum);

for iEigs = 1:eignum
    figure(iEigs)
    v = im * a(:,iEigs);
    imagesc(reshape(v,x,y))
    title(['eig: ' num2str(iEigs)])
    set(gcf,'Color',[1 1 1]);
end

