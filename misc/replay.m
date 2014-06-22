function replay(file,tfps,dif)

tp = tpReader([file 'p%u.h5']);

imCh = getImagingChannel(tp,1);

figure;
colormap gray
set(gcf,'Color',[1 1 1])
siz = size(imCh);
if nargin>1
    txtt = '  Max fps:';
    txtv = 'round(1/t)';
    fps = tfps;
else
    txtt = '';
    txtv = 'txtt';
    fps = getFramerate(tp);
end
t = 0;
first = double(imCh(:,:,1));
clims = ([-1 1]);
for iFrame = 1:siz(3)
    tic;
    if nargin>2
        imagesc((double(imCh(:,:,iFrame)) - first)./first,clims)
    else
         imagesc(imCh(:,:,iFrame))
    end
    title(['Frame: ' num2str(iFrame) ' / ' num2str(siz(3)) txtt num2str(eval(txtv))])
    drawnow
    t = toc;
    if t < 1/fps
        pause(1/fps - t)
    end
end

