function varargout = colorbar(varargin)

style = PlotTool.getStyle('colorbar');

handle = colorbar(style{:},varargin{:});

if nargout == 1
    varargout{1} = handle;
end
