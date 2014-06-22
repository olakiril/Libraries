function [tex tey] = imAmpScramble(tex,c)

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
rindx = randperm(round(numel(amp)/2)-1);
% for i= 1:1000
%     ind = randperm(round(numel(amp)/2)-1);
%     rindx = rindx(ind);
% end
ampr = amp;
ampr(1:round(numel(amp)/2)-1) = ampr(rindx);
hlf = fliplr(ampr(round(numel(amp)/2)+1:end));
ampr(round(numel(amp)/2)+1:end) = fliplr(hlf(rindx));

% grt real image
tey = real(ifftn(ampr.*exp(1i*ifftshift(ft))));

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

