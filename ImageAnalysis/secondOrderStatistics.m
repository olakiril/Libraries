%% single frame 2nd order statistics
path = 'Z:\users\philipp\stimuli\MouseMovie\Mac';
movies{2} = dir([path '\*phs.avi']);
movies{1} = dir([path '\*nat.avi']);
euDist = @(x,y) sqrt(diff(x).^2 + diff(y).^2 );
sampleSize = 10000;

for iMovie = 1:length(movies{1})
    disp(['Movie: ' num2str(iMovie)])
    secStat = struct([]);
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
       
        % get positions and calculate distances
        if iType == 1
            x = randi(vidHeight,[2 sampleSize]);
            y = randi(vidHeight,[2 sampleSize]);
            secStat(1).dist = euDist(x,y);
        end
        
        % calculate correlations
        secStat.corr = nan(sampleSize,1);
        secStat.p = nan(sampleSize,1);
        for iPair = 1:size(x,2);
            [secStat.corr(iPair) secStat.p(iPair)] = corr(permute(mov(x(1,iPair),y(1,iPair),:),[3 2 1]), ...
                permute(mov(x(2,iPair),y(2,iPair),:),[3 2 1]));
        end
        
        % save
        name = [movies{iType}(iMovie).name(1:end-4) '_2ndOrdStats'];
        itry = 1;
        while itry < 10          
            try
                save(name,'secStat');
                itry = 10;
            catch %#ok<CTCH>
                itry = itry + 1;
                display(num2str(itry))
            end
        end
    end
end

%% 2nd order statistics across time

path = 'Z:\users\philipp\stimuli\MouseMovie\Mac';
movies{2} = dir([path '\*phs.avi']);
movies{1} = dir([path '\*nat.avi']);
euDist = @(x,y) sqrt(diff(x).^2 + diff(y).^2 );
sampleSize = 10000;
pixelSize = 100;

for iMovie = 1:length(movies{1})
    disp(['Movie: ' num2str(iMovie)])
    secStat = struct([]);
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
       
        mov = reshape(mov,[],nFrames);
        
        % get positions and calculate distances
        if iType == 1
            x = randi(nFrames,[2 sampleSize]);
            secStat(1).dist = abs(x(1,:) - x(2,:));
            px = randi(size(mov,1),[pixelSize 1]);
        end
        
        % calculate correlations
        secStat.corr = nan(sampleSize,1);
        secStat.p = nan(sampleSize,1);
        for iPair = 1:size(x,2);
            [secStat.corr(iPair) secStat.p(iPair)] = corr(mov(px,x(1,iPair)), ...
                mov(px,x(2,iPair)));
        end
        
        % save
        name = [movies{iType}(iMovie).name(1:end-4) '_2ndOrdStatsTime'];
        itry = 1;
        while itry < 10          
            try
                save(name,'secStat');
                itry = 10;
            catch %#ok<CTCH>
                itry = itry + 1;
                display(num2str(itry))
            end
        end
    end
end

%% prepare the data

path = 'Z:\users\philipp\stimuli\MouseMovie\Mac';
movies{2} = dir([path '\*phs_2ndOrdStats.mat']);
movies{1} = dir([path '\*nat_2ndOrdStats.mat']);
mC = cell(length(movies{1}),1);mD = mC;pC = mC;pD = mC;
for iMovie = 1:length(movies{1})
    
    load([path '\' movies{1}(iMovie).name])
    mC{iMovie} = secStat.corr;
    mD{iMovie} = secStat.dist';
   
    load([path '\' movies{2}(iMovie).name])
    pC{iMovie} = secStat.corr;
    pD{iMovie} = secStat.dist';
end

mD = round(cell2mat(mD));
pD = round(cell2mat(pD));
mC = cell2mat(mC);
pC = cell2mat(pC);

uniN = unique(mD);
uniP = unique(pD);
mDu = nan(length(uniN),1);mCu = mDu;mE = mDu;
pDu = nan(length(uniP),1);pCu = pDu;pE = pDu;
for iUni = 1:length(uniN)
    mDu(iUni) = uniN(iUni);
    mCu(iUni) = nanmean(mC(mD == uniN(iUni)));
    mE(iUni) = nanstd(mC(mD == uniN(iUni)))/sum(mD == uniN(iUni));
end
for iUni = 1:length(uniP)
    pDu(iUni) = uniP(iUni);
    pCu(iUni) = nanmean(pC(pD == uniP(iUni)));
    pE(iUni) = nanstd(pC(pD == uniP(iUni)))/sum(pD == uniP(iUni));
end
%% plot
% Set up fittype and options.
ft = fittype( 'smoothingspline' );
opts = fitoptions( ft );
opts.SmoothingParam = 0.999992747542875;
opts.Normalize = 'on';

% Fit model to data.
[xData, yData] = prepareCurveData( mDu, mCu );
nat = fit( xData, yData, ft, opts );

[xData, yData] = prepareCurveData( pDu, pCu );
phs = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
plot( nat);
hold on
plot(phs,'r')

% Label axes
h = legend('Natural','Phase');
set(h,'Box','off','Location','southeast','LineWidth',1)
xlabel( 'Distance (pixels)' );
ylabel( 'Correlation' );
grid on


    
    