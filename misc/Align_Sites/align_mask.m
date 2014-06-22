function corr_shift = align_mask(maskA,maskB,varargin)

% function corr_shift = align_mask(maskA,maskB,varargin)
%
% corr_shift finds the best alignment for two masks 
% It includes 2d shift and rotation of maskB relative to maskA
%
% MF 2009-12-22

params.maxShift = 50; % radius of shift in real mask pixels
params.imresize = .3; % resize %
params.smooth = 10;   % filter smoothness
params.rotate = 0;   % rotation shift in angles (both directions)

%params = getParams(params,varargin);

% filter the mask
w = gausswin(params.smooth);
w = w * w';
w = w / sum(w(:));
mask1 = convn(maskA,w,'valid');
mask2 = convn(maskB,w,'valid');

% resize masks
mask1 = imresize(mask1,params.imresize);
mask2 = imresize(mask2,params.imresize);

%resize radius
maxShift = round(params.maxShift * params.imresize);

%find matrix expansion size
xmax = max([size(mask1,1) size(mask2,1)]);
ymax = max([size(mask1,2) size(mask2,2)]);
mask_size = ([xmax ymax]) + 2*maxShift;

%initialize
colapsed_matrix = zeros(1,((maxShift*2)^2)*(params.rotate*2+1));
expand_mask = zeros(mask_size(1),mask_size(2));
shift = zeros(((maxShift*2)^2)*(params.rotate*2+1),3);
i = 0;

% expand the mask
mask1big = expand_mask;
mask1big((maxShift+1):maxShift+size(mask1,1),...
    (maxShift+1):maxShift+size(mask1,2)) = mask1;

% start the shifting one by one..
for z = -params.rotate:params.rotate
    mask = imrotate(mask2,z,'nearest','crop');
    for x = 1:maxShift*2
        for y = 1:maxShift*2
            mask2big = expand_mask;
            i = i+1;
            shift(i,:) = [x,y,z];

            % shift the first mask
            mask2big(x+1:(size(mask,1)+x),y+1:(size(mask,2)+ y)) = mask;

            % subtract the two masks, and calculate the absolute sum
            expand_matrix =  mask1big - mask2big;
            colapsed_matrix(i) = sum(sum(abs(expand_matrix)));
            
            % produce % report
            if find(i/length(shift) == 0.1:0.1:1)
                display (['% progress: ' num2str(i*100/length(shift)) ' %']);
            end
        end
    end
end

% take the shift with the minimum residual
corr_shift = shift(colapsed_matrix == min(colapsed_matrix),:);

% correct multiple outomes
corr_shift = round(mean(corr_shift,1));

% correct for initial resize
corr_shift(1:2) = round((corr_shift(1:2) - maxShift)/params.imresize);

%output
if ~nargout
    figure;
    
    subplot(221)
    xmax = max([size(maskA,1) size(maskB,1)]);
    ymax = max([size(maskA,2) size(maskB,2)]);
    xShift = abs(corr_shift(1));
    yShift = abs(corr_shift(2));
    mask_size = ([(xmax+2*xShift) (ymax+2*yShift)]);
    expand_mask = zeros(mask_size(1),mask_size(2));
    mask1big = expand_mask;
    mask1big((xShift+1):xShift+size(maskA,1),...
    (yShift+1):yShift+size(maskA,2)) = maskA;
    mask = imrotate(maskB,corr_shift(3),'nearest','crop');
    mask2big = expand_mask;
    mask2big(corr_shift(1)+1+xShift:(size(mask,1)+corr_shift(1)+xShift),...
        corr_shift(2)+1+yShift:(size(mask,2)+ corr_shift(2)+yShift)) = mask;
    expand_matrix =  mask1big - mask2big;
    imagesc(expand_matrix);
    title('Residual')
    
    subplot(223)
    hist(colapsed_matrix,1000);
    title('Residual distribution for all the shifts')
    xlabel(gca,'Residual Value');
    ylabel(gca,'# shifts');
    set(gca,'box','off');
%     expand_matrix =  mask1big + mask2big;
%     imagesc(expand_matrix);
    
    subplot(2,2,[2 4])
    [X,Y] = meshgrid(-params.maxShift:(params.maxShift)/(maxShift-0.5):params.maxShift);
    Z = zeros(maxShift*2,maxShift*2);
    i = 0;
    max_mask = ((sum(sum(maskA)) + sum(sum(maskB)))/2);
    for x = 1:maxShift*2
        for y = 1:maxShift*2
            i = i+1;
            Z(x,y) = (max_mask - colapsed_matrix(i))/max_mask;
        end
    end
    range = max(max(Z)) - min(min(Z));
    axis([-params.maxShift params.maxShift -params.maxShift params.maxShift min(min(Z))-range/2 max(max(Z))])
    hold on
    meshc(X,Y,Z)
    title('Residual distribution for all the shifts')
    xlabel(gca,'X shift');
    ylabel(gca,'Y shift');
    zlabel(gca,'fraction of area reduction after subtraction');
    
    set(gcf,'Color',[1 1 1])
end
