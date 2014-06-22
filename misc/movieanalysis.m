%%
ms = dir('*.avi');
for iMovie = 1:length(ms)
    display(ms(iMovie).name)
    movie = mmreader(ms(iMovie).name);
    nFrames = movie.NumberOfFrames;
    
    for k = 1 : nFrames
        cdata = read(movie, k);
        cdata = double(cdata(:,:,1));
        stats.mean(k) = mean(cdata(:));
        stats.std(k) = std(cdata(:));
        stats.kurtosis(k) = kurtosis(cdata(:));
    end
    save(ms(iMovie).name(1:strfind(ms(iMovie).name,'.avi')-1),'stats')
end