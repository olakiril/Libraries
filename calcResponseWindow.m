function FWHM = calcResponseWindow(X,fps)

% function FWHM = calcResponseWindow(X)
%
% Estimates the FWHM of the responses by fitting the autocorrelation
% fuction with a guassian function
% INPUT: 
% X: [time cells]
% fps: frames per second of the signal
% OUTPUT: Full width half max in input temporal units

if nargin<2
    fps = 5;
end

% Calculate autocorrelation function for each cell
R = nan(size(X,2),size(X,1)*2-1);
for icell = 1:size(X,2)
    R(icell,:) = xcorr(X(:,icell));
end

% normalize the amplitude for each cell and average across cells to smooth
% out the noise
x = mean(normalize(R,2));

% highpass filter to remove some of the baseline
x = highpass(x,0.005,fps);

% Fit autocorrelation function with a 2nd order gaussian function. 
[xData, yData] = prepareCurveData( [], x );

% Set up fittype and options.
ft = fittype( 'gauss2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0.3 -Inf 0 -Inf -Inf 0]; % first curve cannot have a smaller peak than 0.3 of the input
opts.Upper = [Inf Inf fps*2 Inf Inf Inf]; % first curve cannot have a width of more than 2 sec. 

% Fit model to data.
fitresult = fit( xData, yData, ft, opts );
FWHM = fitresult.c1*2.35482/2; % 2*sqrt(2*log(2))*sigma FWHM of the guassian function. Devide by 2 to account for doubling of the width with the autocorrelation function

