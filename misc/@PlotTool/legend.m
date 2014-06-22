function varargout = legend(text,varargin)

style = PlotTool.getStyle('legend');

handle = legend(text,style{:},varargin{:});

if nargout == 1
    varargout{1} = handle;
end
