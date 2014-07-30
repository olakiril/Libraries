function [X,Y] = alignImages(A,B)

global im1
global im2
global x
global y
global go
global AA
global gain

gain = 10;
AA = A;

% plot the two vessel maps
im2 = normalize(B);
h = figure('NumberTitle','off','Menubar','none',...
    'Name','align Images',...
    'KeyPressFcn',@dispkeyevent);
% im1 = normalize(1./exp(double(A)));
im1 = normalize(1./exp(double(A)/10));
% initialize 
x = 1;
y = 1;

im3 = zeros(size(im1,1),size(im1,2),3);
im3(:,:,1) = im1;
im3(round(x):size(im2,1)+round(x) - 1,...
    round(y):size(im2,2)+round(y) - 1,2) = im2;
clf
imshow(im3)
go = false;
display('Align the images')

% wait until the alignment is done
while ~go && ishandle(h)
    figure(h)
    pause(0.2)
end

X = x;
Y = y;

function dispkeyevent(~, event)

global im1
global im2
global x
global y
global go
global AA
global gain

if strcmp(event.Key,'downarrow')
    if x<size(im1,1);        x = x+1;    end
elseif strcmp(event.Key,'uparrow')
    if x>1;        x = x-1;    end
elseif strcmp(event.Key,'rightarrow')
    if y<size(im1,2);        y = y+1;    end
elseif strcmp(event.Key,'leftarrow')
    if y>1;        y = y-1;    end
elseif strcmp(event.Key,'end')
    if x<size(im1,1);        x = x+20;    end
elseif strcmp(event.Key,'home')
    if x>1;        x = x-20;    end
elseif strcmp(event.Key,'pagedown')
    if y<size(im1,2);        y = y+20;    end
elseif strcmp(event.Key,'delete')
    if y>1; y = y-20;    end
elseif strcmp(event.Key,'rightbracket')
   gain = gain+10;
elseif strcmp(event.Key,'leftbracket')
    gain = gain-10;
elseif strcmp(event.Key,'return')
    go = true;
end

if go
    close(gcf)
else
     im1 = normalize(1./exp(double(AA)/(gain)));
    im3 = zeros(size(im1,1),size(im1,2),3);
    im3(:,:,1) = im1;
    im3(round(x):size(im2,1)+round(x) - 1,...
        round(y):size(im2,2)+round(y) - 1,2) = im2;
    clf
    imshow(im3)
    title(['x: ' num2str(x) ' y: ' num2str(y)])
end