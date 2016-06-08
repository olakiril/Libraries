function alignVessels(key,varargin)

global im1
global im2
global x
global y
global rot
global scale
global vessels
global go

params.sigma = 2; %sigma of the gaussian filter
params.exp = 1; % exponent factor of rescaling
params.direction = 0; % direction of bar
params.testingmode = [];
params.channel = 1;

params = getParams(params,varargin);

import vis2p.*

% get the intrinsic data
keys = fetch(OptImageBar(key,['direction =' num2str(params.direction)]));

% get structural data
if isfield(key,'scan_idx')
    key = rmfield(key,'scan_idx');
end
keysTP = fetch(Scans(key,'aim = "vesselMap" and scan_prog > "Imager"'));

if isempty(keysTP);display('No 2P structure map found! Aborting...');return;end

scpr = fetch1(Scans(keysTP(end)),'scan_prog');
[lens, mag] = fetch1(Scans(keysTP(end)),'lens','mag');
tp = tpReader(Scans(keysTP(end)));

if strcmp(scpr,'MPScan')
    imS = mean(tp.imCh{params.channel}(:,:,:),3);
    % set initial parameters
    rot =-46.5;
    scale = 2.98/(lens*mag);
    x = 37;
    y = 26;
    outFileName =  getFilename(tp);
    outFileName = [outFileName(1:end - 6) '_overview.png'];
else
    imS = mean(tp.read(params.channel),3);
    imS(end+1,:) = imS(end,:);
    % set initial parameters
    rot =-228;
    scale = 3.708/(lens*mag);
    x = 38;
    y = 43;
    outFileName =  tp.filepaths;
    outFileName = [outFileName{1}(1:end - 4) '_overview.png'];
end

imS(imS>prctile(imS(:),99)) = prctile(imS(:),99);


if ~isempty(keys)
    keys = keys(end);
    [imP, imA, vessels] = plot(OptImageBar(keys),'exp',params.exp);
    
    % normalize and filter phase and amplitude map
    iH = imgaussian(normalize(imP),params.sigma);
    iS = imgaussian(normalize(imA),params.sigma);
    
    
    % plot the two vessel maps
    im2 = imresize(normalize(imS),0.5);
    h = figure('NumberTitle','off','Menubar','none',...
        'Name','align Images',...
        'KeyPressFcn',@dispkeyevent);
    vessels = imresize(vessels,0.5);
    im1 = normalize(imrotate(imresize(vessels,1/scale),-rot,'crop'));
    
    im3 = zeros(size(im1,1),size(im1,2),3);
    im3(:,:,1) = im1;
    im3(round(x/scale):size(im2,1)+round(x/scale) - 1,...
        round(y/scale):size(im2,2)+round(y/scale) - 1,2) = im2;
    clf
    imshow(im3)
    go = false;
    display('Align the images')
    
    % wait until the alignment is done
    while ~go && ishandle(h)
        figure(h)
        pause(0.2)
    end
    
    % reshape intrinsic vessel image and index on the selected location
    iI = zeros(size(im1));
    iI(round(x/scale):size(im2,1)+round(x/scale) - 1,...
        round(y/scale):size(im2,2)+round(y/scale) - 1) = ones(size(im2));
    iH = imrotate(imresize(imresize(iH,0.5),1/scale),-rot,'crop');
    iH = imresize(reshape(iH(logical(iI)),size(im2)),1/0.5);
    iS = imrotate(imresize(imresize(iS,0.5),1/scale),-rot,'crop');
    iS = imresize(reshape(iS(logical(iI)),size(im2)),1/0.5);
    
    iV = normalize(imS);
    
        if ~strcmp(scpr,'MPScan')
            iH = rot90(iH,2);
            iS = rot90(iS,2);
            iV = rot90(iV,2);
        end
    
    % convert to rgb space
    im = (hsv2rgb(cat(3,iH,cat(3,iS,iV))));
else
    display('Saving just the vessel map...')
    im = normalize(imS);
end

if params.testingmode
    figure
    imshow(im)
else
    imwrite(im, outFileName, 'png');
end

function dispkeyevent(~, event)

global im1
global im2
global x
global y
global rot
global scale
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
    if scale<1
        scale = scale+0.01;
    end
elseif strcmp(event.Key,'hyphen')
    if scale>0
        scale = scale-0.01;
    end
elseif strcmp(event.Key,'return')
    go = true;
end

if go
    close(gcf)
else
    im1 = normalize(imrotate(imresize(vessels,1/scale),-rot,'crop'));
    im3 = zeros(size(im1,1),size(im1,2),3);
    im3(:,:,1) = im1;
    im3(round(x/scale):size(im2,1)+round(x/scale) - 1,...
        round(y/scale):size(im2,2)+round(y/scale) - 1,2) = im2;
    clf
    imshow(im3)
    %         display(['X:' num2str(x) ' Y:' num2str(y) 'rot:' num2str(rot) ' scale:' num2str(scale)])
end