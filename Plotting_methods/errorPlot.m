function hout = errorPlot(times,traces,varargin)
% h = errorPlot(times,traces)
%
% This function makes a nice plot with the mean and std of the traces.  Can
% also pass an optional parameter 'sem' for standard error of the mean
%
% JC 2008-07-16

params.method = 'std';
params.style = 'k';
params.barFunction = 'patch';
params.errorColor = [0 0 0];
params.FaceAlpha = .2;
params.manual = 0;
params.linestyle = '-';
params.linewidth = 1;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

if ~params.manual
    if strcmpi(params.method,'std')
        err = nanstd(traces);
    elseif strcmpi(params.method,'sem');
        err = nanstd(traces)/sqrt(size(traces,1));
    else
        error('Unsupported method');
    end

    m = nanmean(traces,1);
else
    m = params.manual(1,:);
    err = params.manual(2,:);
end

if isempty(times)
    times = 1:length(m);
end

if strcmpi(params.barFunction,'patch')
    h2 = patch([times fliplr(times)],[m-err, fliplr(m+err)],params.errorColor, 'FaceAlpha', params.FaceAlpha, 'EdgeColor', 'none');
elseif strcmpi(params.barFunction,'area')
    h2 = area([times fliplr(times)],[m-err, fliplr(m+err)],'FaceColor', params.errorColor, 'EdgeColor', 'none');
else
    error('Unsupported error function');
end
set(h2,'HandleVisibility','off') % legend does not capture the errors
hold on
h = plot(times,m,params.style,'Color',params.errorColor,...
    'linestyle',params.linestyle,'linewidth',params.linewidth);

if nargout>0
    hout = h;
end
