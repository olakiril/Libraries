function [tex tey] = imPhaseScramble(tex,c)

% norm
mn = mean(tex(:));
sx = std(tex(:));
tex = (tex - mn) / sx;

% make sure image sizes are odd
evn = ~mod(size(tex),2);
tex = tex(1:end - evn(1),1:end - evn(2));

% compute phase and amplitude spectrums
ft = angle(fftshift(fftn(tex)));
amp = abs(fftn(tex));          % amplitude spectrum

% randomize phase spectrums
rindx = randperm(round(numel(ft)/2)-1);
% for i= 1:1000
%     ind = randperm(round(numel(ft)/2)-1);
%     rindx = rindx(ind);
% end
ftr = ft;
ftr(1:round(numel(ft)/2)-1) = ftr(rindx);
hlf = fliplr(ftr(round(numel(ft)/2)+1:end));
ftr(round(numel(ft)/2)+1:end) = fliplr(hlf(rindx));

% grt real image
tey = real(ifftn(amp.*exp(1i*ifftshift(ftr))));

% fill the range of values & normalize
if nargin<2
    c = min([abs(min(tex(:))) max(tex(:))]);
end 
tex(tex<-c) = -c;   tex(tex>c) = c;
tex = (tex + c) / 2 / c;
tey(tey<-c) = -c;   tey(tey>c) = c;
tey = (tey + c) / 2 / c;

% tranform to proper format
tex = uint8(ceil(tex*255));
tey = uint8(ceil(tey*255));

