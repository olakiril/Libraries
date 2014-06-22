function retIds = clickCell(sitename,neuropil)

global dataCon
sessMan = getContext(dataCon,'Session');

siteId  = filterElementByMeta(sessMan, 'Site', 'datafile', sitename );
assert(~isempty(siteId), sprintf('Site %s not found', sitename ) );

cellIds = getDescendantsByType(sessMan,siteId,'Cell');
neuropilId = getDescendantsByType(sessMan,siteId,'Neuropil');
assert( ~isempty(cellIds), sprintf('No cells in %s', sitename));

greenImage = getImage( getData(dataCon,siteId,'Image','type','ch1') );
greenImage = greenImage/quantile( greenImage(:), 0.98 );
redImage   = getImage( getData(dataCon,siteId,'Image','type','ch2') );
redImage   = redImage/quantile( redImage(:), 0.98 );
siteImg = cat(3, redImage, cat( 3, greenImage, zeros(size(redImage)))); 

oriCells = getData( dataCon, cellIds, 'OriCellDim' ); 
[pvalue, prefOri, prefDir ] = getTuning( oriCells );

% plot cells as fitted circles 
[xi, yi] = meshgrid( 1:size(siteImg,2), 1:size(siteImg,1 ) );
h = zeros(size(greenImage));
s = zeros(size(greenImage)); 
v = zeros(size(greenImage));  
cells = getElementById( dataCon, cellIds );
a = getMetaDataVec( cells, 'circAmp' );
x = getMetaDataVec( cells, 'circX');
y = getMetaDataVec( cells, 'circY');
r = getMetaDataVec( cells, 'circRadius');
p = getMetaDataVec( cells, 'circShape');
a = max(a,max(a));  %make all cells of same amplitude
for iCell = 1:length(cells)
    blob = makeCircularCell(xi,yi,[a(iCell) x(iCell) y(iCell) r(iCell) p(iCell)]);
    hue = prefOri(iCell)/180;  % hue denotes orientation
    h = h + (blob > 0.1*a(iCell)).*(hue-h); % binary hue
    s = s + (blob/a(iCell)).*((pvalue(iCell) < 0.05)-s); % binary saturation
    %s = s + blob/a(iCell).*(max(0,(-1-log10(max(0.001,pvalue(iCell))))/2)-s);   % saturation proportional to log(pvalue);
    v = v + blob; 
end
v = max( greenImage, 1.2*v );
v = v./max(v(:));
imshow( hsv2rgb( cat(3, h, cat(3, s, v)))) ;  title( 'Orientations of detected cells' );
hold on;
for iCell = 1:length(cells)
    h = rectangle( 'Position', [[x(iCell) y(iCell)]-r(iCell) [2 2]*r(iCell)], 'curvature', [1 1] ); 
    set(h,'LineStyle', ':');
    if( pvalue(iCell)< 0.05)
        plot( x(iCell) + sin( prefOri(iCell)*pi/180 )*[-1 1]*1.2*r(iCell)...
            , y(iCell) + cos( prefOri(iCell)*pi/180 )*[-1 1]*1.2*r(iCell)...
            , 'k.-', 'LineWidth', 0.25, 'MarkerSize', 3 );
    end
    text( x(iCell), y(iCell), sprintf('%d', cellIds( iCell )), 'fontsize', 9, 'Color', [1 1 1] );
end
hold off;

[xu,yu] = ginput;
dist = sqrt(bsxfun( @minus, x, xu ).^2 + bsxfun( @minus, y, yu ).^2);
[dist, midx] = min( dist' );
retIds = cellIds( midx( dist < r(midx) ) );
if nargin > 2 
    retIds = [retIds neuropilId];
end
plotCells( retIds, sessMan );
fprintf('Found %d cells of %d clicks\n', length(retIds), length(dist) );
