function varargout = bisector(varargin)

args.keepAxis = false;
args = parseVarArgs(args,varargin{:});

style = PlotTool.getStyle('bisector');
lim = [xlim; ylim]; 
a = min(lim(:,1));
b = max(lim(:,2));
handle = plot([a b],[a b],style{:});

if nargout > 0
    varargout{1} = handle;
end

if ~args.keepAxis
    PlotTool.sqAx
end
