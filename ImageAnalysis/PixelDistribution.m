% Gets the pixel distribution information

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

        name = [movies{iType}(iMovie).name(1:end-4) '_cK'];
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

%%
path = 'Z:\users\philipp\stimuli\MouseMovie\Mac';
movies{2} = dir([path '\*_nat.mat']);
movies{1} = dir([path '\*_phs.mat']);

mP = cell(length(movies{1}),1);mS = mP;mK = mP;pP = mP;pS = mP;pK = mP;
for iMovie = 1:length(movies{1})

    load([path '\' movies{1}(iMovie).name])
    mP{iMovie} = stats.mean;
    mS{iMovie} = stats.std;
    mK{iMovie} = stats.kurtosis;
    
    load([path '\' movies{2}(iMovie).name])
    pP{iMovie} = stats.mean;
    pS{iMovie} = stats.std;
    pK{iMovie} = stats.kurtosis;
    
end

histdiff(cell2mat(mS'),cell2mat(pS'),'bin',60,'names',{'nat','phs'},'title','Pixel std difference (frame)')
histdiff(cell2mat(mP'),cell2mat(pP'),'bin',60,'names',{'nat','phs'},'title','Pixel mean difference (frame)')
histdiff(cell2mat(mK'),cell2mat(pK'),'bin',400,'names',{'nat','phs'},'title','Pixel kurtosis difference (frame)')
