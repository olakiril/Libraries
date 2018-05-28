function [tex, tey, tez] = phaseScramble(tex,pretty,flatAmplitude)

% function [tex, tey, tez] = phaseScramble(tex,pretty,flatAmplitude)
%
% phaseScramble can scramble the phase & the amplitude spectrum of an image
% or movie while preserving the complex conjugate structure.
%
% Inputs
% tex          : [x y frames] Grayscale image or video. Accepts doubles/singles. 
% pretty       : Change the normalization:
%          i)0/[] sets the same range as the normalized natural image (default)
%         ii)1 gets the range from both the natural and phase scrmabled images
%        iii)2 set
% flatAmplitute: Sets a flat amplitude spectrum instead of randomized
%
%Outputs
%tex           : natural image/movie normalized to [0 1]
%tey           : phase scrambled image/movie normalized to [0 1]
%tez           : amplitude/phase scrambled image/movie normalized to [0 1]

% fix random seed
rng(0)

% normalize pixel intensities
mx = mean(tex(:));
sx = std(tex(:));
tex = (tex - mx) / sx;

% make sure image sizes are odd
evn = ~mod(size(tex),2); if size(tex,3)==1;evn(3) = 0;end
tex = tex(1:end - evn(1),1:end - evn(2),1:end - evn(3));

% compute phase and amplitude spectrums
phs = angle(fftshift(fftn(tex))); % phase spectrum
amp = abs(fftn(tex));             % amplitude spectrum

% randomize phase spectrums
rindx = randperm(round(numel(phs)/2)-1);
for i = 1:1000
   rindx = rindx(randperm(round(numel(phs)/2)-1));
end

% amplitude spectrum calculations 
if nargout>2
    if nargin>2 % flat amplitude
         amp2 = ones(size(amp));
    else % random amplitude
        amp2 = amp;
        amp2(1:round(numel(amp2)/2)-1) = amp2(rindx);
        hlf = fliplr(amp2(round(numel(amp2)/2)+1:end));
        amp2(round(numel(amp2)/2)+1:end) = fliplr(hlf(rindx));
    end
    phs2 = phs;
end

% randomize the matrix while preserving the complex conjugate structure
phs(1:round(numel(phs)/2)-1) = phs(rindx);
hlf = fliplr(phs(round(numel(phs)/2)+1:end));
phs(round(numel(phs)/2)+1:end) = fliplr(hlf(rindx));

% clear variables to save memory
clear hlf rindx

% gnrt real image
tey = real(ifftn(amp.*exp(1i*ifftshift(phs))));

% estimate the normalization value
if nargin<2 || pretty==0
    c = min([abs(min(tex(:))) max(tex(:))]);
elseif pretty==1
    c = max([abs(min(tex(:))) max(tex(:)) abs(min(tey(:))) max(tey(:))]);
elseif pretty==2
    c = prctile(tey(:),99);
else
    display('normalization input not regognized!')
    c = min([abs(min(tex(:))) max(tex(:))]);
end

% set the range of values
tex(tex<-c) = -c;   tex(tex>c) = c;
tex = (tex + c) / 2 / c;
tey(tey<-c) = -c;   tey(tey>c) = c;
tey = (tey + c) / 2 / c;


% if asked normalize the scrambled amplitude spectrum
if nargout>2
    tez = real(ifftn(amp2.*exp(1i*ifftshift(phs2))));
    tez(tez<-c) = -c;   tez(tez>c) = c;
    tez = (tez + c) / 2 / c;
end
