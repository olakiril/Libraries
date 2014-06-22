function [x y z h] = getPosition(traces,time,coordinates)

params.smoothing = 5;
params.plot = 1;

idx = findGrid(coordinates);
for i = 1:size(coordinates,1)/400
    idx{i} = (i-1)*400+1:(i-1)*400+400;
end

for i = 1:length(idx)
    n = sqrt(length(idx{i}));
    mot = reshape(traces(:,idx{i})',[n n size(traces,1)]);
    thr = quantile(double(mot(:)),.25);
    mot = mot - thr; 
    mot(mot(:) < 0) = 0;
    for j = 1:size(traces,1)
        im = double(mean(mot(:,:,max(1,j-params.smoothing):min(end,j+params.smoothing)),3));
        
        x(j,i) = sum(coordinates(idx{i},1) .* im(:)) / sum(im(:));
        y(j,i) = sum(coordinates(idx{i},2) .* im(:)) / sum(im(:));
        z(j,i) = sum(coordinates(idx{i},3) .* im(:)) / sum(im(:));
    end
%    mi(:,:,i) = mean(mot(:,:,1:100),3);
end

if params.plot
    h(1) = subplot(311); plot(time,bsxfun(@minus,x,mean(x))); ylabel('X movement (um)');
    h(2) = subplot(312); plot(time,bsxfun(@minus,y,mean(y))); ylabel('Y movement (um)');
    h(3) = subplot(313); plot(time,bsxfun(@minus,z,mean(z))); ylabel('Z movement (um)');
    xlabel('Time (sec)')
%     figure;
%     for i = 1:size(mi,3)
%         subplot(1,size(mi,3),i);
%         imagesc(mi(:,:,i));
%     end
else h = [];
end