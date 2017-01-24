function out = createGrating(imSize,theta,lamda,phase)

if ~nargin
    imSize = 540;                           % image size: n X n
end

if nargin<2
    theta = 90;                             % grating orientation
end

if nargin<3
    lamda = 120;                            % wavelength (number of pixels per cycle)
end

if nargin<4
    phase = .25;                            % phase (0 -> 1)
end

X = 1:imSize;                           % X is a vector from 1 to imageSize
X0 = (X / imSize) - .5;                 % rescale X -> -.5 to .5

freq = imSize/lamda;                    % compute frequency from wavelength
phaseRad = (phase * 2* pi);             % convert to radians: 0 -> 2*pi

[Xm, Ym] = meshgrid(X0, X0);            % 2D matrices

thetaRad = (theta / 360) * 2*pi;        % convert theta (orientation) to radians
Xt = Xm * cos(thetaRad);                % compute proportion of Xm for given orientation
Yt = Ym * sin(thetaRad);                % compute proportion of Ym for given orientation
XYt = [ Xt + Yt ];                      % sum X and Y components
XYf = XYt * freq * 2*pi;                % convert to radians and scale by frequency
grating = sin( XYf + phaseRad);                   % make 2D sinewave

if ~nargout
    figure;                                 % make new figure window
    imagesc( grating, [-1 1] );                     % display
    colormap gray(256);                     % use gray colormap (0: black, 1: white)
    axis off; axis image;    % use gray colormap
else
    out = grating;
end
