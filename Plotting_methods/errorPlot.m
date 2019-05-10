function hout = errorPlot(times,traces,varargin)
% h = errorPlot(times,traces)
%
% This function makes a nice plot with the mean and std of the traces.  Can
% also pass an optional parameter 'sem' for standard error of the mean
%
% JC 2008-07-16

params.method = 'sem';
params.style = 'k';
params.barFunction = 'patch';
params.errorColor = [0 0 0];
params.FaceAlpha = .2;
params.manual = [];
params.linestyle = '-';
params.linewidth = 1;
params.average = 'nanmean';
params.prc = .9;

for i = 1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

if isempty(params.manual)
    if any(strcmp(params.average,{'nanmean','mean'}))
        m = nanmean(traces,1);
        cifun = @meanci;
    elseif any(strcmp(params.average,{'nanmedian','median'}))
        m = nanmedian(traces,1);
        cifun = @medianci;
    else
        error('Unsupported averaging method');
    end
    
    if strcmpi(params.method,'std')
        errU = nanstd(traces);
        errL = m - errU;
        errU = m + errU;
    elseif strcmpi(params.method,'sem')
        errU = nanstd(traces)/sqrt(size(traces,1));
        errL = m - errU;
        errU = m + errU;
    elseif strcmpi(params.method,'ci')
        errU = [];errL = [];
        for y = 1:size(traces,2)
            [errU(y), errL(y)] = cifun(traces(:,y),params.prc);
        end
    else
        error('Unsupported method');
    end

else
    m = params.manual(1,:);
    errU = params.manual(2,:);
    errL = errU;
end

if isempty(times)
    times = 1:length(m);
end

if strcmpi(params.barFunction,'patch')
    h2 = patch([times fliplr(times)],[errL, fliplr(errU)],params.errorColor, 'FaceAlpha', params.FaceAlpha, 'EdgeColor', 'none');
elseif strcmpi(params.barFunction,'area')
    h2 = area([times fliplr(times)],[errL, fliplr(errU)],'FaceColor', params.errorColor, 'EdgeColor', 'none');
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
