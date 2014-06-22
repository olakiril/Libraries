function [amp, ang, pwr, mot, ofmov] = extractMotion(file,rect,index,varargin)

% function [amp, ang, pwr, mot, ofmov] = extractMotion(file,rect,index,varargin)
%
% extractMotion computes the optic flow of an avi file frame by frame and
% calculates the amplitude and angle of the coherent motion, and the
% average power of all the flow vectors.
%
% INPUTS:
% file:     Location of the avi file
% rect:     rectc coordinates of the ROI to analyze (see imcrop)
% index:    index of the locations to include in the mean vector
%
% OUTPUTS:
% amp:      The length of the resulting average vector (strength of the
%           coherent motion in arbitrary units)
% ang:      The angle of the resulting vector (degrees)
% pwr:      The power of all the motion vectors.
% mot:      The motion up,down,left,right for each frame
% ofmov:    The optic flow for the whole movie
%
% PARAMETERS:
% preview:     Displays the resulting motion vectors
% size_factor: Arbitrary vector scale that depends on the expected number
%              of motion vectors in the image. Adjusted so the range is [0 1]
% noise:       Motion Threshold for noise reduction. The higher the number,
%              the less small movements impact the optical flow calculation.
%
% EXAMPLE:
% file= getLocalPath('/lab/users/philipp/stimuli/MouseMovie/Mac/mov7_nat.avi');
% extractMotion(file,[],[],'preview',1);
%
% MF 2013-12

% check if file exists
if ~exist(file,'file'); disp 'File does not exist'; return;end

% rounding function
roundall = @(x) round(x.*10.^abs(floor(log10(x))))./10.^abs(floor(log10(x)));

% set default parameters
params.preview = 0;
params.size_factor = 10;
params.noise = 0.004;

% update parameters
for i = 1:2:length(varargin);params.(varargin{i}) = varargin{i+1};end

% Video parameters
videoReader = vision.VideoFileReader(file,'ImageColorSpace','Intensity',...
    'VideoOutputDataType','uint8');
converter = vision.ImageDataTypeConverter;

% Optic Flow parameters
opticalFlow = vision.OpticalFlow('Method','Lucas-Kanade');
opticalFlow.OutputValue = 'Horizontal and vertical components in complex form';
opticalFlow.NoiseReductionThreshold = params.noise;
opticalFlow.TemporalGradientFilter = 'Derivative of Gaussian';

% Video Preview parameters
if params.preview
    shapeInserter = vision.ShapeInserter('Shape','Lines',...
        'BorderColor','Custom', 'CustomBorderColor', 255);
    videoPlayer = vision.VideoPlayer('Name','Motion Vector');
end

% initialize variables
ang = []; amp = []; pwr = []; iframe = 0;

% loop throught all the frames of the movie
while ~isDone(videoReader)
    frame = step(videoReader);iframe = iframe+1; % Move to the next frame
    im = step(converter, frame);                 % Convert the frame
    if nargin>1 && ~isempty(rect) && ~params.preview
        im = imcrop(im,rect); end                % Select Subset of the movie
    of = step(opticalFlow, im);                  % Calculate the optic flow
    if nargin>2 && ~isempty(index) && ~params.preview
        of = of(index); end                      % select motion vecs
    Xvec = nansum(reshape(real(of),[],1));       % Vectors X
    Yvec = nansum(reshape(imag(of),[],1));       % Vectors Y
    if nargout>3;
        mot.up(iframe) =  nanmean(Xvec(Xvec<0));
        mot.down(iframe) =  nanmean(Xvec(Xvec>0));
        mot.left(iframe) =  nanmean(Yvec(Yvec<0));
        mot.right(iframe) =  nanmean(Yvec(Yvec>0));
        if nargout>4; ofmov(:,:,iframe) = of;end % store the values
    end
    alen = sqrt(Xvec.^2 + Yvec.^2)/numel(of);    % Vector mean
    amp(iframe) = alen*params.size_factor;       % Arbitrary units!
    
    if nargout>1 || params.preview
        % calculate the angle of the average motion vector
        angle = atand(abs(Xvec/Yvec));
        if sign(Xvec)==1 && sign(Yvec)==1
            angle = abs(angle-90)+90;
        elseif sign(Xvec)==-1 && sign(Yvec)==1
            angle = angle+180;
        elseif sign(Xvec)==-1 && sign(Yvec)==-1
            angle = abs(angle-90)+270;
        end
        ang(iframe) = angle;
        
        if nargout>2 || params.preview                 % compute the power
            power = abs(of);
            if nargin>2 && ~isempty(index)
                power = power(index); end
            pwr(iframe) = nanmean(power(:));
        end
        
        % plot stuff
        if params.preview
            lines = videooptflowlines(of,10);          % Convert to lines
            if ~isempty(lines)
                out =  step(shapeInserter, im, lines); % inset lines in im
                step(videoPlayer, out);                % display the frame
                
                clf
                subplot(131)
                if nargin>1 && ~isempty(rect)
                    out = out.*(mask+1); end
                imagesc(out)
                axis image
                title('Motion Vectors')
                
                subplot(132)
                if nargin>1 && ~isempty(rect)
                    power = power.*(mask+1); end
                imagesc(power)
                axis image
                title(['Motion power: ' num2str(roundall(nanmean(power(:))))])
                
                subplot(133)
                alen = roundall(params.size_factor*alen);
                plot([0 cosd(angle)*alen],[0 sind(angle)*alen])
                xlim([-1 1]);
                ylim([-1 1]);
                set(gca,'xtick',[],'ytick',[])
                axis square
                title(['Angle:' num2str(round(angle)) ' Amp:' num2str(alen)])
                drawnow
                pause(0.1)
            end
        end
    end
end

% correct for extra timepoint
amp = amp(2:end);
if ~isempty(ang);ang = ang(2:end);end
if ~isempty(pwr);pwr = pwr(2:end);end

% Close the video player
if params.preview
    release(videoPlayer);
    release(videoReader);
end

