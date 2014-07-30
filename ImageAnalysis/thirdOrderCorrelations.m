% Gets 3rd order correlations

%% read movies
path = 'Z:\users\philipp\stimuli\MouseMovie\Mac';
movies{2} = dir([path '\*phs.avi']);
movies{1} = dir([path '\*nat.avi']);

for iMovie = 1:length(movies{1})
    disp(['Movie: ' num2str(iMovie)])
    for iType = 1:2
        movie = mmreader([path '\' movies{iType}(iMovie).name]); %#ok<TNMLP>
        nFrames = movie.NumberOfFrames;
        vidHeight = movie.Height;
        vidWidth = movie.Width;
        % Preallocate movie structure.
        mov = zeros(vidHeight, vidWidth,nFrames);
        
        % Read one frame at a time.
        for iFrame = 1 : nFrames
            mov(:,:,iFrame) = mean(read(movie, iFrame),3);
        end
        mov = mov(:,1:size(mov,1),:);
        i = 1;
        for iangle = 0:15:75
            imr = imrotate(mov,iangle,'crop');
            imr = imr(75:end-75,75:end-75,:);
            im = reshape(imr(:,1:10:end,1:5:end),size(imr,1),[]);
            stats.bi(:,:,1,i) = bispecd(im);
            im = reshape(permute(imr(1:10:end,:,1:5:end),[2 1 3]),size(imr,2),[]);
            stats.bi(:,:,2,i) = bispecd(im);
            stats.co(:,:,2,i) = fftshift(real(ifftn(fftshift(stats.bi(:,:,2,i)))));
            stats.co(:,:,1,i) = fftshift(real(ifftn(fftshift(stats.bi(:,:,1,i)))));
            i= i +1;
        end
        
        name = [movies{iType}(iMovie).name(1:end-4) '_bispectrum'];
        itry = 1;
        while itry < 10
            try
                save(name,'stats');
                itry = 10;
            catch %#ok<CTCH>
                itry = itry + 1;
                display(num2str(itry))
            end
        end
    end
end

%% plot

path = 'Z:\users\philipp\stimuli\MouseMovie\Mac';
movies{2} = dir([path '\*phs.avi']);
movies{1} = dir([path '\*nat.avi']);

for iMovie = 1:1%length(movies{1})
    disp(['Movie: ' num2str(iMovie)])
    for iType = 1:2
        name = [movies{iType}(iMovie).name(1:end-4) '_bispectrum'];
        load ([name '.mat'])
        co(:,:,:,:,iMovie,iType) = stats.co;
    end
end

% nat = mean(mean(mean(cov(:,:,:,:,:,1),5),4),3);
% phs = mean(mean(mean(cov(:,:,:,:,:,2),5),4),3);
% imagesc([nat phs])

nat = mean(co(:,:,:,4,1,1),3);
phs = mean(co(:,:,:,4,1,2),3);
%%
clim = [0 0.006];
figure
subplot(121)
n = imresize(nat(129:end - 128,129:end - 128),1);
surfl(n)
title('natural')
set(gca,'XTick',0:256/8:256)
set(gca,'XTickLabel',[-128 -96 -64 -32 0 32 64 96 128])
set(gca,'YTick',0:256/8:256)
set(gca,'YTickLabel',[-128 -96 -64 -32 0 32 64 96 128])
% set(gca,'ZLim',[-0.002 0.006])
xlabel('pixel(a) lag')
ylabel('pixel(b) lag')
shading interp
subplot(122)
p = imresize(phs(129:end - 128,129:end - 128),1);
surfl(p)
title('phase Scr')
set(gca,'XTick',0:256/8:256)
set(gca,'XTickLabel',[-128 -96 -64 -32 0 32 64 96 128])
set(gca,'YTick',0:256/8:256)
set(gca,'YTickLabel',[-128 -96 -64 -32 0 32 64 96 128])
% set(gca,'ZLim',[-0.002 0.006])
xlabel('pixel(a) lag')
ylabel('pixel(b) lag')
shading interp
colormap(gray);
set(gcf,'Color',[1 1 1])

%% second
movie = mmreader([path '\' movies{1}(2).name]);
nFrames = movie.NumberOfFrames;
vidHeight = movie.Height;
vidWidth = movie.Width;
% Preallocate movie structure.
mov = zeros(vidHeight, vidWidth,nFrames);
% Read one frame at a time.
for iFrame = 1 : nFrames
    mov(:,:,iFrame) = mean(read(movie, iFrame),3);
end
mov = mov(:,1:size(mov,1),:);
% [xs ys] = size(mov);
% f2 = -xs/2:xs/2-1;
% f1 = -ys/2:ys/2-1;
% [XX YY] = meshgrid(f1,f2);
% [t r] = cart2pol(XX,YY);
% c = (max(r(:)) - r)/2 + 1;
% clear xnm
xn = zeros(200*2+1,size(mov,2),360);
for iframe = 1:360
    for icolumn = 1:size(mov,2)
        xn(:,icolumn,iframe) = xcorr(mov(:,icolumn),200,'unbiased');
    end
    %     x = xcorr2(mov(:,:,i));
    %     xs = ceil(size(mov,1))/2;
    %     ys = ceil(size(mov,2))/2;
    %     x = x(xs:end-xs,ys:end-ys)/c;
    %     xnm(:,i) = sfPlot(x/max(x(:)));
end

movie = mmreader([path '\' movies{2}(2).name]);
nFrames = movie.NumberOfFrames;
vidHeight = movie.Height;
vidWidth = movie.Width;
% Preallocate movie structure.
mov = zeros(vidHeight, vidWidth,nFrames);
% Read one frame at a time.
for iFrame = 1 : nFrames
    mov(:,:,iFrame) = mean(read(movie, iFrame),3);
end
mov = mov(:,1:size(mov,1),:);

xp = zeros(200*2+1,size(mov,2),360);
for iframe = 1:360
    for icolumn = 1:size(mov,2)
        xp(:,icolumn,iframe) = xcorr(mov(:,icolumn),200,'unbiased');
    end
end
% for i = 1:360
%     xp = xcorr(mov(:,:,i),50,'unbiased');
%     xp = xp(ceil(size(xp)/2):end,:);
%     xpm(:,i) = mean(xp,2);
% end

%% figure
% nxn = bsxfun(@rdivide,xn,max(xn,[],1));
% npn = bsxfun(@rdivide,xp,max(xp,[],1));
xnn = mean(mean(xn(302:352,:,:),3),2);
xpp = mean(mean(xp(302:352,:,:),3),2);

figure;
plot(xnn,'b')
hold on
plot(xpp,'r')
set(gcf,'Color',[1 1 1])
set(gca,'Box','Off')
xlabel('Spatial separation (pixels)')
ylabel('Correlation coefficient');
l= legend('nat','phase');
set(l,'EdgeColor',[1 1 1])

%% rot average xcorr2
path = 'Z:\users\philipp\stimuli\MouseMovie\Mac';
movies{2} = dir([path '\*phs.avi']);
movies{1} = dir([path '\*nat.avi']);
M = ones(240,240,36,22,2);
R = ones(120,36,22,2);
for iMovies = 1:length(movies{1})
    display(num2str(iMovies))
    for iType = 1:2
        movie = mmreader([path '\' movies{iType}(iMovies).name]); %#ok<TNMLP>
        nFrames = movie.NumberOfFrames;
        h = movie.H;
        ifr = 0;
        for iFrame = 1 : 10: nFrames
            ifr = ifr + 1;
            mov = mean(read(movie, iFrame),3);
            mov = mov(:,1:h,:);
            mos = mov(h/4 + 1:end - h/4,h/4 + 1:end - h/4);
            x = xcorr2(mos,mov);
            M(:,:,ifr,iMovies,iType) = x(h/2 :end - h/2,h/2 :end - h/2);
            R(:,ifr,iMovies,iType) = sfPlot(M(:,:,ifr,iMovies,iType));
        end
    end
end
%% plot it
figure
nat = mean(mean(R(:,:,:,1),3),2);
phs = mean(mean(R(:,:,:,2),3),2);
plot(nat)
hold on
plot(phs,'r')
% plot norm
figure
Rn = bsxfun(@rdivide,R,R(1,:,:,:));
% nat = nanmean(nanmean(Rn(:,:,:,1),3),2);
% phs = nanmean(nanmean(Rn(:,:,:,2),3),2);
nat = reshape(Rn(:,:,:,1),size(Rn,1),[]);
phs = reshape(Rn(:,:,:,2),size(Rn,1),[]);
nm = mean(nat(:, nat(end,:)<mean(nat(2:end,:),1)),2);
pm = mean(phs,2);
ne = std(nat(:, nat(end,:)<nat(1,:)),[],2)/sqrt(size(nat(:, nat(end,:)<nat(1,:)),2));
pe = std(phs(:, phs(end,:)<phs(1,:)),[],2)/sqrt(size(phs(:, phs(end,:)<phs(1,:)),2));
plot(nat)
hold on
plot(phs,'r')
% plot norm
% figure
% Rn = bsxfun(@rdivide,R,R(1,:,:,:));
% indx = [6 9 22 25]';
% i
% nat = reshape(Rn(:,:,:,1),size(Rn,1),[]);
% phs = reshape(Rn(:,:,:,2),size(Rn,1),[]);
% plot(nat,'b')
% hold on
% plot(phs,'r')