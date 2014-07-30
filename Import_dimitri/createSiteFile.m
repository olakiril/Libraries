function fail = createSiteFile(prefix,mag,lens,photodiode,electrophysiology,segment)
% ts = createSiteFile(prefix,mag,photodiode,electrophysiology)
%
% This function creates site files to be used by Steinbruch for the imaging
% things.  Pass a prefix to the the file that has been aligned.  It also returns
% the timestamps just to make things easier.
%
% JC 2008-05-17
% DY 2009-05-19  Replaced threshold descend with parametric fit 

verbose = true;  % make false to turn off progress report and intermediate plots

siteFile = struct( 'meanCh1'      , []...
                 , 'meanCh2'      , []...
                 , 'alignmentInfo', []...
                 , 'mask'         , []...
                 , 'likelihoods'  , []...   %is this required anywhere?
                 , 'cells'        , []...
                 , 'neuropil'     , []...
                 , 'neuroglia'    , []...
                 , 'vessels'      , []);

fail =  ~exist([prefix, 'p0.h5'],'file') && lens > 0 && mag > 0;

if ~fail 
    tpr = tpReader([prefix, 'p%u.h5']);
    [chIm,chEl,chAligned] = getChannels(tpr);
    fail = isempty(chAligned);
    if fail
        warning('createSiteFile:NotEnoughChannels', ...
                  'Both OGB-1 and SR-101 channels are required to process TP datasets (%s), skipping dataset.',prefix);
    else
        imageChannel1 = getAlignedImagingChannel(tpr,chAligned(1));
        siteFile.meanCh1 = mean( getData(imageChannel1), 3);
        if length(chAligned)<2
            warning('Processing dataset %s with only one channel. You should record both channels', prefix);
            siteFile.meanCh2 = zeros(size(siteFile.meanCh2));
        else
            imageChannel2 = getAlignedImagingChannel(tpr,chAligned(2));
            siteFile.meanCh2 = mean( getData(imageChannel2), 3);
        end
        if ~isStack(tpr) && ~isnan(segment) && segment           
            minRadius = 0.18*mag*lens;   % rule of thumb for the min cell radius
            minDistance = minRadius*2.2; % rule of thumb for the min distance between cell centers
            maxCells = round(min(300, 0.25*prod(size(siteFile.meanCh1)+minDistance)/minDistance.^2));  % rule of thumb for max # of cells

            if verbose, tic, end 
            [siteFile.circularFits, cleanImg, residual] ...
                = fitCircularCells( siteFile.meanCh1, 'minRadius', minRadius...
                                                    , 'minDistance', minDistance...
                                                    , 'maxCells', maxCells...
                                                    , 'fitThreshold', 0.90....
                                                    , 'ampThreshold', 0.4 );
                                                    
            ncells = length( siteFile.circularFits.amplitude ); 

            if verbose, toc, end;
            
            % display results 
            if verbose 
                img1 = log(siteFile.meanCh1); img1 = max(0,img1 - prctile(img1(:),5));  img1 = min(1,img1/prctile(img1(:),98));
                img2 = log(siteFile.meanCh2); img2 = max(0,img2 - prctile(img2(:),5));  img2 = min(1,img2/prctile(img2(:),98));
                subplot(221); imagesc(cat(3,cat(3,img2,img1),zeros(size(img1))));       
                    axis image;  title('log cellImage');
                subplot(222); imagesc( cleanImg-residual );  axis image;  title('fitted reconstruction');
                subplot(223); imagesc(cleanImg,[0 max(cleanImg(:))]);  axis image;  title('normalized ');
                subplot(224); imagesc(residual ); axis image;  title('residual');
                colormap(gray);
                drawnow;
                fprintf('Extracted %d cells\n', length(siteFile.circularFits.amplitude));
            end            
            % create mask and compute fluorescence ratio 
            siteFile.mask = ones(size( siteFile.meanCh1 ));  % neuropil is designated as 1
            [yi, xi] = ndgrid( 1:size(siteFile.mask,1), 1:size(siteFile.mask,2) );
            fluorescenceRatio = zeros(1,ncells);
            ch2 = siteFile.meanCh2/max(max(siteFile.meanCh2));
                       
            for icell = ncells:-1:1  % in reverse order to place bigger cells last
                idx = find( (xi - siteFile.circularFits.x(icell)).^2 + ...
                    (yi - siteFile.circularFits.y(icell)).^2 < 0.7*siteFile.circularFits.radius(icell).^2 );
                idx2 = find( (xi - siteFile.circularFits.x(icell)).^2 + ...
                    (yi - siteFile.circularFits.y(icell)).^2 < ... 
                    0.7*(siteFile.circularFits.radius(icell)*1.5).^2 );
                idx3 = idx2((ismember(idx2,idx)<1));
                fluorescenceRatio( icell ) = mean(ch2(idx3))/mean(ch2(idx));                
                siteFile.mask( idx ) = icell+1;  % 1 is reserved for neuropil
                
            end
            
            siteFile.cells = find( fluorescenceRatio >= 0.88 );  
            siteFile.neuroglia = setdiff( 1:ncells, siteFile.cells ); 
            
            siteFile.likelihoods = ones(1,ncells+1); %for dimitris new method we dont need likelihoods any more
            
            if verbose
                for i=[1 3]
                    subplot(2,2,i);
                    hold on; 
                    plot( siteFile.circularFits.x(siteFile.cells), siteFile.circularFits.y(siteFile.cells), '+', 'Color',[1 1 1]);
                    plot( siteFile.circularFits.x(siteFile.neuroglia), siteFile.circularFits.y(siteFile.neuroglia), 'r+');
                    hold off;
                end
                subplot(221);
                hold on;
                for icell = siteFile.cells
                    text(  siteFile.circularFits.x(icell),  siteFile.circularFits.y(icell), sprintf('%d',icell), 'Color', [0.5 0.5 1], 'fontsize', 5);
                end
                hold off;
                drawnow;   
                print('-dpng', [prefix '_cells']);
            end
            
            siteFile.cells = siteFile.cells + 1;   % 1 is designated for the neuropil
            siteFile.neuroglia = siteFile.neuroglia + 1;  % 1 is designated for the neuropil

            fail = false;           
        end
    end       
end

if ~fail 
    save([prefix,'_site.mat'],'siteFile');
end