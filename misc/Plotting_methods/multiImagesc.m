function multiImagesc(matrix3d,varargin)

% function multiImagesc(matrix3d,varargin)
%
% plots multiple matrices with one huge colorbar
%
% MF 2009-06-01

params.clims = [-0.5 0.5];

params = getParams(params,varargin);

conditionNum = size(matrix3d,3);

sequence = 1:conditionNum;
screen = reshape(sequence,5,[])';

xsize = ceil(sqrt(conditionNum)+1);
ysize = ceil(conditionNum/xsize);

barsite = [];
for i = 1:size(screen,1)
    barsite(end+1) = (size(screen,2)+1)*i;
    screen(screen>=(size(screen,2)+1)*i) = screen(screen>=(size(screen,2)+1)*i)+1;
end
    
for i = 1:conditionNum
    subplot(ysize,xsize,screen(i))
    imagesc(matrix3d(:,:,i),params.clims);
    axis('off')
end


subplot(ysize,xsize,barsite)
imagesc((params.clims(2):0.01:params.clims(1))',params.clims);
set(gca,'box','off','XGrid','off')
axis('off')
colorbar('West');

set (gcf,'Color',[1 1 1]);