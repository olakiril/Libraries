function out = movieStats(movieNum,functions,varargin)

params.bin = 100;
params.pixels = 20;
params.frames = 300;
params.exp_date = '2012-01-01'; % to get the latest movies
params.movie_type = 'natural';
params.method = 'conv';

params = getParams(params,varargin);

% stim times and types of movies shown
if datenum(params.exp_date,'yyyy-mm-dd')>datenum('2011-12-01','yyyy-mm-dd')
    path = getLocalPath('/lab/users/philipp/stimuli/MouseMovie/MacNew/mov1l11s');
else
    path = getLocalPath('/lab/users/philipp/stimuli/MouseMovie/Mac/mov');
end

for ivar = 1:length(functions)
    eval(['val' num2str(ivar) '=cell(length(movieNum),length(params.bin),length(params.pixels));']);
end

% loop through different movies shown
for iMov = 1:length(movieNum)
    display(num2str(movieNum(iMov)))
    if strcmp(params.movie_type,'phase')
        type = 'phs';
    else
        type = 'nat';
    end
    movie = mmreader([path num2str(movieNum(iMov)) '_' type '.avi']); %#ok<TNMLP>
    nFrames = min([movie.NumberOfFrames params.frames]);
    
    % do it frame by frame
    MOVIE = nan(movie.Height,movie.Width,nFrames);
    for iFrame = 1 : nFrames
        MOVIE(:,:,iFrame) = mean(read(movie,iFrame),3);
    end
    
    for ibin = 1:length(params.bin)
        d = max([1 round(movie.FrameRate*(params.bin(ibin)/1000))]);
        
        if strcmp(params.method,'conv')
            mov = permute(MOVIE,[3 1 2]);
            mov = convn(mov,ones(d,1)/d,'valid');
            mov = permute(mov(1:d:end,:,:),[2 3 1]);
        elseif strcmp(params.method,'bin')
            indx = 1:d:size(MOVIE,3);
            M = nan(size(MOVIE,1),size(MOVIE,2),length(indx));
            for iFrame = 1:length(indx)
                mx = min([indx(iFrame)+d-1 size(MOVIE,3)]);
                M(:,:,iFrame) = mean(MOVIE(:,:,indx(iFrame):mx),3);
            end
            mov = M;
        end
        
        for iFrame = 1:size(mov,3)
            data = mov(:,:,iFrame);
            for ipixel = 1:length(params.pixels)
                
                if params.pixels~=1
                    % resize the pixel space
                    data = imresize(data,sqrt(numel(data)\params.pixels(ipixel)));
                end
                
                % do the computations
                for ivar = 1:length(functions)
                    eval(['val' num2str(ivar) '{iMov,ibin,ipixel}(iFrame) = ' num2str(feval(functions{ivar},data(:))) ';']);
                end
            end
        end
    end
end

out = cell(length(functions),1);
for ivar = 1:length(functions)
    eval(['out{ivar} = val' num2str(ivar) ';'])
end


