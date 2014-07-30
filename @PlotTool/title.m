function varargout = title(text,varargin)

style = PlotTool.getStyle('title');

handle = title(text,style{:},varargin{:});

if nargout == 1
    varargout{1} = handle;
end
