%  [psfs, fwhm] = extractPSF( tpStack, pitch );
%
%  extract and plot PSFs from an image stack of beads
%
%  INPUTS:
%   tpStack - tpReader object of the image stack from which to compute the PSFs
%   pitch  - [dx,dy,dz] (um/pixel)
%
%  OUTPUTS:
%   psfs - a cell array of extracted PSFs
%   fwhm - (um) n x 3 array containing x,y,z FWHMs for each of the extracted psfs
%       FWHM = full width at half magnitude
%   resolution - similar to FWHM, but instead of half-magnitude, 1-exp(-1)=0.63 magnitude is used.
%
% DY: 2010-08-12


function [psfs,fwhm,resolution] = extractAOD_PSFs( filename, pitch, varargin )

%assert( isStack(tpStack), 'The two-photon file must be a stack');
assert( isnumeric(pitch) && length(pitch)==3, 'The second argument must be contain pixel pitch as [x,y,z]');

params.numpsfs = 21; % maximum number of psfs fo extract
params.thresh = 0.8;   % the amplitude threshold of beads as a fraction of max max peak
params.spacing = [1 1 5];  % (um) xyz distance in each direction to include in the space around the PSFs
params.showFigures = true;
params.colormap = 1-gray(256); % colormap to use for plots
params.printPDF = false;
params.comment =  '';   % comment to add to the titles of the figures.

params = parseVarArgs( params, varargin{:}, 'assert');

pitch  = pitch([2 1 3]);   % xyz -> yzx to make matlab happy
params.spacing = params.spacing([2 1 3]);  % xyz -> yzx to make matlab happy

stack = loadAODStack(filename);
stack = mean(stack,4);
sz = size(stack);

if params.showFigures
    % plot the z projection of entire stack
    figure;
    temp = sqrt(max(0,max(stack,[],3)));  % equalize variance, expand dynamic range
    image((1:sz(2))*pitch(2),(1:sz(1))*pitch(1), size(params.colormap,1)*temp/max(temp(:)));
    colormap(params.colormap);
    title(sprintf('%s max z-projection', params.comment));
    xlabel('x (um)'); ylabel('y (um)');
%     set( gca, 'Units', 'pixels', 'Position', [50 50 sz(1:2)]);
%     set( gcf, 'Units', 'pixels', 'Position', [200 200 sz(1:2)+100]);

end



% extract spaces around peaks
s = smoothStack( -stack );
s = s/max(s(:));  %normalize the image
yi = (1:sz(1))*pitch(1);
xi = (1:sz(2))*pitch(2);
zi = (1:sz(3))*pitch(3);
[y3,x3,z3] = ndgrid(yi,xi,zi);

psfs = {};
fwhm = [];
resolution = [];
for iPSF=1:params.numpsfs
    [amp,idx] = max(s(:));
    if amp<params.thresh
        disp('no more peaks');
        break;
    end
    [ys,xs,zs] = ind2sub( sz, idx );  % the coordinates of the peak in the smoothed stack

    % extract PSF
    a = round( params.spacing./pitch );
    psfs{iPSF} = stack(max(1,ys-a(1)):min(end,ys+a(1))...
        ,max(1,xs-a(2)):min(end,xs+a(2))...
        ,max(1,zs-a(3)):min(end,zs+a(3)));
    s(max(1,ys-a(1)):min(end,ys+a(1))...
        ,max(1,xs-a(2)):min(end,xs+a(2))...
        ,max(1,zs-a(3)):min(end,zs+a(3)))=0;   % blot out the extracted blob


    % compute marginals, FWHMs, and resolutions
    xmarg = squeeze(mean( psfs{iPSF},2))';
    xmarg = xmarg/max(xmarg(:));
    ymarg = squeeze(mean( psfs{iPSF},1))';
    ymarg = ymarg/max(ymarg(:));
    zmarg = squeeze(mean( psfs{iPSF},3));
    zmarg = zmarg/max(zmarg(:));

    xymarg = mean(ymarg,2);  xymarg=xymarg-quantile(xymarg,0.10); xymarg = xymarg/max(xymarg);
    yzmarg = mean(zmarg,1);  yzmarg=yzmarg-quantile(yzmarg,0.10); yzmarg = yzmarg/max(yzmarg);
    xzmarg = mean(xmarg,1);  xzmarg=xzmarg-quantile(xzmarg,0.10); xzmarg = xzmarg/max(xzmarg);

    fwhm(1,iPSF) = runLength(yzmarg>0.5)*pitch(2); 
    fwhm(2,iPSF) = runLength(xzmarg>0.5)*pitch(1);
    fwhm(3,iPSF) = runLength(xymarg>0.5)*pitch(3);
    
    resolution(1,iPSF) = runLength(yzmarg>1-exp(-1))*pitch(2); 
    resolution(2,iPSF) = runLength(xzmarg>1-exp(-1))*pitch(1);
    resolution(3,iPSF) = runLength(xymarg>1-exp(-1))*pitch(3);

    % visualize PSFs
    if params.showFigures
        figure; % ('PaperUnits', 'centimeters', 'PaperSize', [30 20], 'PaperPosition', [0 0 30 20], 'Units', 'centimeters', 'Position', [0 0 30 20]);

        % Z projection
        subplot(231);
        image( (-(size(zmarg,2)-1)/2:(size(zmarg,2)-1)/2)*pitch(2), (-(size(zmarg,1)-1)/2:(size(zmarg,1)-1)/2)*pitch(1), size(params.colormap,1)*zmarg ); colormap(params.colormap);
        xlabel( 'x (um)' );  ylabel( 'y (um)' );   title( 'Z projection' );
        axis image;

        % xz and yz marginals
        subplot(234);
        plot( (-(length(yzmarg)-1)/2:(length(yzmarg)-1)/2)*pitch(2), yzmarg, 'r' );
        hold on;
        plot( (-(length(xzmarg)-1)/2:(length(xzmarg)-1)/2)*pitch(1), xzmarg, 'g' );
        legend( 'x-axis', 'y-axis' ); legend boxoff;
        plot( xlim, [0 0], 'k-.');  
        plot( xlim, [0.5 0.5], 'k-.');  
        plot( xlim, [1 1]-exp(-1), 'k-.');
        hold off; box off
        title( sprintf( 'FWHM_x=%1.2f, FWHM_y=%1.2f, \\Delta_x=%1.2f, \\Delta_y=%1.2f'...
            , fwhm(1,iPSF), fwhm(2,iPSF), resolution(1,iPSF), resolution(2,iPSF) ));
        xlabel('x (um)'); ylabel('magnitude');

        % X projection
        subplot(232);
        image( (-(size(xmarg,2)-1)/2:(size(xmarg,2)-1)/2)*pitch(2), (-(size(xmarg,1)-1)/2:(size(xmarg,1)-1)/2)*pitch(3), size(params.colormap,1)*xmarg ); 
        colormap(params.colormap);
        xlabel( 'y (um)' );  ylabel( 'z (um)' );   title( 'X projection' );
        axis image;
        
        % Y projection
        subplot(233);
        image( (-(size(ymarg,2)-1)/2:(size(ymarg,2)-1)/2)*pitch(1), (-(size(ymarg,1)-1)/2:(size(ymarg,1)-1)/2)*pitch(3), size(params.colormap,1)*ymarg );
        colormap(params.colormap);
        xlabel( 'x (um)' );  ylabel( 'z (um)' );   title( 'Y projection' );
        axis image;
        

        subplot(2,3,5:6);
        plot( (-(length(xymarg)-1)/2:(length(xymarg)-1)/2)*pitch(3), xymarg );
        xlabel( 'z (um)' ); ylabel('magnitude');
        hold on;
        plot( xlim, [0 0], 'k-.');  
        plot( xlim, [0.5 0.5], 'k-.');  
        plot( xlim, [1 1]-exp(-1), 'k-.');
        hold off; box off;
        title( sprintf( 'FWHM_z=%1.2f, \\Delta_z=%1.2f', fwhm(3,iPSF), resolution(3,iPSF) ) );

        suptitle(sprintf('%s PSF %d',params.comment,iPSF));
        if params.printPDF
            set( gcf, 'PaperUnits', 'inches', 'PaperSize', [8,6], 'PaperPosition',[0,0,8,6]);
            pdfFile=sprintf( './%s_PSF%02d.pdf', 'beads02_2', iPSF );
            fprintf( 'Saving %s\n', pdfFile );
            print('-dpdf',pdfFile);
        end
    end
end



function l=runLength( above )
if above(1) || above(end)
    l = nan;
else
    l = find(above,1,'last')-find(above,1,'first');
end



function m = smoothStack( m )
k = hamming(5); k = k/sum(k);
m = imfilter( imfilter( m, k, 'symmetric' ), k', 'symmetric' );