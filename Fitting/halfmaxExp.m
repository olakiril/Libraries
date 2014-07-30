function halfmax = halfmaxExp(n)

% Prepare
[xData, yData] = prepareCurveData( [], n );

% Set up fittype and options.
ft = fittype( 'exp2' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf -Inf];
opts.StartPoint = [0.499469934353739 0.045052677838094 -0.070501778695731 -0.889988703872311];
opts.Upper = [Inf Inf Inf Inf];
opts.Normalize = 'on';

% Fit model to data.
fitresult = fit( xData, yData, ft, opts );

m = mean(predint(fitresult,0:0.1:length(n)),2);
[~,halfmax] = min(abs(m - max(m)/2));
halfmax = halfmax/10;
