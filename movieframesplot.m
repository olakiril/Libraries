%%
frames = 20;
startIndx = 1;
endIndx = 300;
numFrames = get(mov, 'numberOfFrames');


index = startIndx:(endIndx - startIndx)/frames:endIndx;
m = uint8(zeros(mov.Height,mov.Width,3,frames));

for i = 1:frames
    m(:,:,:,i) = read(mov,index(i));
end

for i = frames:-1:1
    if i == frames
        subplot(4,4,4)
    else
        subplot(4,4,1)
    end
    image(m(:,:,:,i));
    if i ~= frames
        set(gca,'position',[pos(1)-0.01 pos(2)-0.01 pos(3) pos(4)])
    end
    set(gca,'Visible','off')
    pos = get(gca,'position');
end