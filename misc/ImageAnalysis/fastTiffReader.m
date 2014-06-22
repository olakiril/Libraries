FileTif='Q:/130903_002.tif';
tic;InfoImage=imfinfo(FileTif);toc

mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
tic;FinalImage=ones(nImage,mImage,NumberImages,'uint16');toc
FileID = tifflib('open',FileTif,'r');
rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);
%%
tic;
for i=1:NumberImages
    tifflib('setDirectory',FileID,i-1);
    % Go through each strip of data.
    rps = min(rps,nImage);
    for r = 1:rps:nImage
        row_inds = r:min(nImage,r+rps-1);
        stripNum = tifflib('computeStrip',FileID,r)-1;
        FinalImage(row_inds,:,i) = tifflib('readEncodedStrip',FileID,stripNum);
    end
end
toc

%%
FileTif='Q:/130903_002.tif';
tic;InfoImage=imfinfo(FileTif);toc

mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
tic;FinalImage=ones(nImage,mImage,NumberImages,'uint16');toc
FileID = tifflib('open',FileTif,'r');
rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);
%%
tic;
t = Tiff('Q:/130903_002.tif', 'r');
im = ones( t.getTag('ImageLength'), t.getTag('ImageWidth'),50000,'uint16');
t.setDirectory(1)
for i=1:size(im,3);
    try
        if i~=1; t.nextDirectory();end
        im(:,:,i) = t.read();
    catch
        im = im(:,:,1:i-1);
        break
    end
end
t.close();
toc
%%
tic;
copyfile('M:/Two-Photon/2013-09-03/130903_002.tif','Q:/test.tif')
toc
%%
