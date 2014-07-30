function cellMatrix = align_cells(masks,varargin)

% function cellMatrix = align_cells(mask1,masks,varargin)
%
% align_cells aligns the cells between different masks.
% Accepts a mask1 as a 2d array and the masks in a cell array that contains
% the rest of the mask that are actually aligned.
% Output is a matrix with maskIds of the cells in rows and the masks in columns
%
% Mf 2009-12-22

params.areaThr = 0.5;
params.allCells = 1;

params = getParams(params,varargin);

mask1 = masks{1};
masks(1) = [];
cellMatrix = zeros(length(unique(mask1))-1,length(masks)+1);
corr_shift = zeros(length(masks),3);
xmax = size(mask1,1);
ymax = size(mask1,2);
xShift = [];
yShift = [];


for masksIndx = 1:length(masks);
    display (['processing mask ' num2str(masksIndx) '/' num2str(length(masks))]);
    mask2 = masks{masksIndx};
   
    % normalize masks
    maskA = mask1 ~= 1;
    maskB = mask2 ~= 1;

    % get shifting information
    corr_shift(masksIndx,:) = align_mask(maskA,maskB);
    
    % find mean values
    xmax = max([xmax size(mask2,1)]);
    ymax = max([xmax size(mask2,2)]);
    xShift = max([xShift abs(corr_shift(masksIndx,1))]);
    yShift = max([yShift abs(corr_shift(masksIndx,2))]);
end

%calculate larger mask
mask_size = ([(xmax+2*xShift) (ymax+2*yShift)]);
expand_mask = zeros(mask_size(1),mask_size(2));

% mask1
mask1big = expand_mask;
mask1big((xShift+1):xShift+size(mask1,1),...
    (yShift+1):yShift+size(mask1,2)) = mask1;

bigMasks = zeros(size(expand_mask,1),size(expand_mask,2),length(masks)+1);
bigMasks(:,:,1) = mask1big;

for masksIndx = 1:length(masks);
    % mask2
    mask = imrotate(masks{masksIndx},corr_shift(masksIndx,3),'nearest','crop');
    mask2big = expand_mask;
    mask2big(corr_shift(masksIndx,1)+1+xShift:(size(mask,1)+corr_shift(masksIndx,1)+xShift),...
        corr_shift(masksIndx,2)+1+yShift:(size(mask,2)+ corr_shift(masksIndx,2)+yShift)) = mask;
    bigMasks(:,:,masksIndx + 1) = mask2big;
    
    % mask corrected
    for i = 2:length(unique(mask1))
        mask2cell = mask2big(mask1big == i);
        uniqueCells = unique(mask2cell);
        cells = zeros(1,length(uniqueCells));
        for j = 1:length(uniqueCells)
            cells(j) = sum(mask2cell == uniqueCells(j));
        end
        [a b] = max(cells);
        if a/length(find(mask2big==i))>= params.areaThr && uniqueCells(b) >1
            cellMatrix(i-1,[1 masksIndx+1]) = [i uniqueCells(b)];
        end
    end
end

% get rid of rows with no cells
if params.allCells
    a = (cellMatrix==0);
    b = sum(a,2);
    cellMatrix(b~=0,:) = [];
end

if ~nargout
    corr_masks = zeros(size(expand_mask,1),size(expand_mask,2),length(masks)+1);
    corr_mask = zeros(size(expand_mask,1),size(expand_mask,2)); 
    for i = 1:length(masks)+1
        mask = bigMasks(:,:,i);
        uni = unique(cellMatrix(:,i));
        for j = 1:length(uni)
            corr_mask(mask == uni(j)) = 1;
            corr_masks(:,:,i) = corr_mask;
        end
    end
    imagesc(sum(corr_masks,3));
    title('overlaping masks')  
end

        
        
        
        
        
        
        
        

