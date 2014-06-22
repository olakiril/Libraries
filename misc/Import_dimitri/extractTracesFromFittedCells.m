function traces = extractTracesFromFittedCells( tpr, siteFile )

[chIm, chEl, chAligned] = getChannels( tpr );
imageChannel = getAlignedImagingChannel(tpr,chAligned(1));

assert(~isempty(chAligned)); 
[yi,xi] = ndgrid( 1:size(siteFile.mask,1), 1:size(siteFile.mask,2) );

data = getData( getAlignedImagingChannel(tpr,chAligned(1)));
sz = size( data );

allcells = union( siteFile.cells, siteFile.neuroglia );
traces = zeros( sz(3), max(allcells) );

% extract neuropil trace
idx = find(siteFile.mask == 1);
for iframe=1:sz(3)
    frame = data(:,:,iframe);
    traces(iframe,1) = mean(frame(idx));
end

% extract all other traces
data = double(reshape(data,[sz(1)*sz(2) sz(3)]));
for icell = allcells -1
    idx = find( (xi - siteFile.circularFits.x(icell)).^2 + (yi - siteFile.circularFits.y(icell)).^2 < 4*siteFile.circularFits.radius(icell)^2);
    mask = makeCircularCell( xi(idx), yi(idx), ...
        [ 1 ...
        , siteFile.circularFits.x(icell) ...
        , siteFile.circularFits.y(icell) ...
        , siteFile.circularFits.radius(icell) ...
        , siteFile.circularFits.shape(icell) ]);
    mask = mask / sum(mask(:));
    
    traces( :, icell+1 ) = data(idx,:)'*mask(:);
    fprintf('cell [%3d/%3d]\n', icell, length(allcells));
end
disp('done');