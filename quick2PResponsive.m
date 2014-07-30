function [z rho p meanIm] = quick2PResponsive(tpr,computeRho)
% This quickly determines pixels that are responsive to stimulus
%
% [z rho p] = quick2PResponsive(tpr)
%
% Takes in a tpReader object, uses the photodiode to detect the frames 
% where the stimulus is on, then converts on/off responsiveness to a z
% score.  rho is the correlation coefficient of each pixel with the 
% stimulus, and p is the significance.
%
% requires /lab/libraries/TwoPhoton/io and /lab/libraries/TwoPhoton/utilities



[onsets,offsets,flips] = filterPhotodiodeFlip(tpr.elCh{1});
spf = double(getSamplesPerFrame(tpr.elCh{1}));
onsets = floor(onsets/spf);
offsets = ceil(offsets/spf); 

disp(sprintf('Found %d onsets\n',length(onsets)));

onFrames = [];
for i = 1:length(onsets)
    onFrames = [onFrames, onsets(i):offsets(i)];
end
offFrames = setdiff(1:size(tpr.imCh{1},3),onFrames);

dat = getData(tpr.imCh{1});
dim1 = size(dat,1);
dim2 = size(dat,2);
dim3 = size(dat,3);

dat = reshape(dat,prod([dim1 dim2]),dim3)';
stim(onFrames) = 1;
stim(offFrames) = 0;

% for i = 1:size(tpmr,2)
% i    
% keyboard
% SingleCorrVector = corrcoef(tpmr(:,1),stim)
% CorrVector(i) = SingleCorrVector(2,1);   
% end
% 
% keyboard
% 
% 
% keyboard
% z = 0;
onMean = mean(dat(onFrames,:),1);
offMean = mean(dat(offFrames,:),1);
offStd = std(double(dat(offFrames,:)),[],1);

z = reshape((onMean-offMean)./offStd,dim1,dim2); 

stim(onFrames) = 1;
stim(offFrames) = 0;
figure;
rho = zeros(dim1,dim2);
p = zeros(dim1,dim2);
for i = 1:prod([dim1 dim2])
    if mod(i,1000) == 0
        disp(sprintf('[%d/%d]',i,prod([dim1 dim2])));
    end
    
    [rho(i) p(i)] = corr(double(dat(:,i)),stim');
end

meanIm = reshape(mean(dat,1),dim1,dim2);

subplot(211);
imagesc(meanIm);
subplot(212);
imagesc(rho);
colorbar
