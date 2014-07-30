function opticalMap2P(fn,tf,varargin)

% function opticalMap(fn,tf,varargin)
%
% Analyzes the intrinsic imaging data aquired with OptImage
%
% MF 2012-06

params.fft = 0; % if positive, it also specifies the radius in pixels around the center that the amplitude spectrum is computed on.
params.sigma = 3; %sigma of the gaussian filter
params.gauss = 50; %size of gaussian window in pixels
params.vessels = []; % vessels image as backround

params = getParams(params,varargin);

if nargin<2
    tf = 0.1585:.0002:0.1615; % plot multiple temporal frequencies
end

%%
 tp = tpReader(fn);
 Fs = getFramerate(tp);

  data = permute(tp.imCh{2}(:,:,:),[3 1 2]);
   imsize = size(data);
 
data = (bsxfun(@minus,data(:,:),mean(data(:,:)))); % subtract mean for the fft

T = 1/Fs; % frame length
L = size(data,1); % Length of signal
t = (0:L-1)*T; % time series

%%
figure
for itf = 1:length(tf)
    subplot(ceil(sqrt(length(tf))),ceil(sqrt(length(tf))),itf)
    R = exp(2*pi*1i*t*tf(itf))*data;
    imP = squeeze(reshape((angle(R)),imsize(2),imsize(3)))';
    imA = squeeze(reshape((abs(R)),imsize(2),imsize(3)))';
    imA(imA>prctile(imA(:),99)) = prctile(imA(:),99);
    
    direc = fileparts(fn);
     vname = dir([direc '/' params.vessels]);
    if ~isempty(params.vessels) && ~isempty(vname)
        vessels = single(loadHWS([direc '/' params.vessels],'imaging','movie')); % get the imaging data
        vessels = permute(reshape(vessels,imsize(2),[],imsize),[2 1 3]); % reshape into [time x y]

        h = normalize(imP);
        s = normalize(imA);
        v = normalize(squeeze(mean(vessels))');
    else
        h = normalize(imP);
        s = ones(size(imP));
        v = normalize(imA);
    end
    Im = (hsv2rgb(cat(3,h,cat(3,s,v))));
    Im = imgaussian(Im,params.sigma,params.gauss);
    image(Im)
    title([num2str(tf(itf)) ' cyc/sec'])
end

% plot the amplitude spectum
if params.fft
    figure
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    
    indx = zeros(imsize);
    indx(imsize/2 - params.fft:imsize/2 + params.fft,...
        imsize/2 - params.fft:imsize/2 + params.fft) = 1;
    Y = fft(data(:,indx(:)),NFFT)/L;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    
    % Plot single-sided amplitude spectrum.
    plot(f,mean(2*abs(Y(1:NFFT/2+1,:)),2))
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
    
end