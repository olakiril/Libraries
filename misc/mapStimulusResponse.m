function [zscore tstat pvalue meanIm] = mapStimulusResponse(path,varargin)
% Computes and plots stimulus responsiveness maps from an image stack. Uses
% the photodiode signal to detect the frames where the stimulus is on.
% When used without return parameters, plots the results. With return
% parameters, the plotting is suppressed.
%
% Example usage:
% mapStimulusResponse /stor01/Two-Photon/090412/090412_013;
% [zscore, tstat, pvalue, meanIm] = mapStimulusResponse( '/stor01/Two-Photon/090412/090412_013' );
%
% Return parameters (or plotted images):
%   'zscore' of stimulus ON frames response per pixel
%   'tstat'  t statistics per pixel
%   'pvalue' p-value significance test per pixel
%   'meanIm' is the mean image
%
% DY 2009-04-28
% MF 2009-05-08


params.resize = 0;

params = getParams (params,varargin);

path = getLocalPath([path 'p%u.h5']);
assert( exist(sprintf(path,0),'file')==2, 'File not found');

% extract synchronized binary stimulus signal
tpr = tpReader(path);
data = getData(tpr.imCh{1});
if params.resize
    imageData = zeros(ceil(size(data,1)*params.resize),ceil(size(data,2)*params.resize),size(data,3));
    for i = 1:size(data,3)
        imageData(:,:,i) = imresize(data(:,:,i),params.resize);
    end
else 
    imageData = double(data);
end

[onsets,offsets] = filterPhotodiodeFlip(tpr.elCh{1});
spf = double( getSamplesPerFrame(tpr.elCh{1}) );
onsets  = ceil(onsets /spf);   % ceil to compensate for Matlab's 1-based indexing
offsets = ceil(offsets/spf)+1;
assert(length(onsets)==length(offsets) ...
    && all(onsets < offsets)...
    && isempty(intersect(onsets,offsets)), 'Invalid stimulus onset or offset');
sz = size(imageData);
stim = zeros(1,sz(3));
stim(onsets) = 1;
stim(offsets) = -1;
stim = cumsum(stim);
fprintf('Found %d onsets\n',length(onsets));

avgs = zeros(sz(1), sz(2), 2); % averages for ON and OFF conditions
vars = zeros(sz(1), sz(2), 2); % variances for ON and OFF conditions
N(1) = sum(stim==0);
N(2) = sum(stim==1);
for iframe = 1:sz(3)
    frame = imageData(:,:,iframe);
    ix = stim(iframe)+1;
    vars(:,:,ix) = vars(:,:,ix) + frame.^2/N(ix);
    avgs(:,:,ix) = avgs(:,:,ix) + frame   /N(ix);
end
vars = max (0, vars - avgs.^2); % variance
difference = avgs(:,:,2) - avgs(:,:,1);
zscore = difference./sqrt(vars(:,:,1));

% t statistics and pvalue
s2x = vars(:,:,2); nx = N(2);
s2y = vars(:,:,1); ny = N(1);
s2xbar = s2x ./ nx;
s2ybar = s2y ./ ny;
dfe = (s2xbar + s2ybar) .^2 ./ (s2xbar.^2 ./ (nx-1) + s2ybar.^2 ./ (ny-1));
se = sqrt(s2xbar + s2ybar);
tstat = difference ./ se;
pvalue = 2*tcdf(-abs(tstat),dfe) ;  % max of one- and two-tailed distributions % changed


% mean image
meanIm = avgs(:,:,1)*N(1) + avgs(:,:,2)*N(2);

% plot results if not returning
if nargout == 0
    figure
    subplot(221);   imagesc( meanIm );  title('Mean image'); axis image;
    subplot(222);   imagesc( zscore,[0 1]); colorbar; title('zscore');  axis image;
    subplot(223);   imagesc( tstat, [0 1] ); colorbar; title('t stat');  axis image;
    subplot(224);   imagesc( 1-pvalue ); colorbar; title('1-(p value)'); axis image;
end


set(gcf,'Color',[1 1 1]);
