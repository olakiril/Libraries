function [position, rotation, scale] = alignImages(imA,imB)

global im1
global im2
global x
global y
global rot
global scl
global vessels
global go

% set initial parameters
rot =0;
scl = 1;
x = round(size(imA,1)/2);
y = round(size(imA,2)/2);

% plot the two vessel maps
im2 = normalize(imB);
h = figure('NumberTitle','off','Menubar','none',...
    'Name','align Images',...
    'KeyPressFcn',@dispkeyevent);
test = zeros(size(imA)*2);
test(round(size(imA,1)/2):round(size(imA,1)/2)+size(imA,1)-1,...
    round(size(imA,2)/2):round(size(imA,2)/2)+size(imA,2)-1) = normalize(imA);
vessels = test;
im1 = test;

im3 = zeros(size(im1,1),size(im1,2),3);
im3(:,:,1) = im1;
im3(round(size(imA,1)/2):round(size(imA,1)/2)+size(imA,1)-1,...
    round(size(imA,2)/2):round(size(imA,2)/2)+size(imA,2)-1,2) = im2;
clf
imshow(im3)
go = false;
display('Align the images')

% wait until the alignment is done
while ~go && ishandle(h)
    figure(h)
    pause(0.1)
end

position = [x-round(size(imA,1)/2) y-round(size(imA,2)/2)];
rotation = rot;
scale = scl;

function dispkeyevent(~, event)

global im1
global im2
global x
global y
global rot
global scl
global vessels
global go

if strcmp(event.Key,'downarrow')
    if x<size(im1,1)/2
        x = x+1;
    end
elseif strcmp(event.Key,'uparrow')
    if x>1
        x = x-1;
    end
elseif strcmp(event.Key,'rightarrow')
    if y<size(im1,2)/2
        y = y+1;
    end
elseif strcmp(event.Key,'leftarrow')
    if y>1
        y = y-1;
    end
elseif strcmp(event.Key,'comma')
    rot = rot+0.5;
elseif strcmp(event.Key,'period')
    rot = rot-0.5;
elseif strcmp(event.Key,'equal')
    scl = scl+0.01;
elseif strcmp(event.Key,'hyphen')
    if scl>0
        scl = scl-0.01;
    end
elseif strcmp(event.Key,'return')
    go = true;
end

if go
    close(gcf)
else
    im1 = normalize(imrotate(imresize(vessels,1/scl),-rot,'crop'));
    im3 = zeros(size(im1,1),size(im1,2),3);
    im3(:,:,1) = im1;
    im3(round(x/scl):size(im2,1)+round(x/scl) - 1,...
        round(y/scl):size(im2,2)+round(y/scl) - 1,2) = im2;
    clf
    imshow(im3)
%         display(['X:' num2str(x) ' Y:' num2str(y) 'rot:' num2str(rot) ' scl:' num2str(scl)])
end