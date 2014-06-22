function varargout = text(x,y,t,varargin)

style = PlotTool.getStyle('text');

handle = text(x,y,t,style{:},varargin{:});

if nargout == 1
    varargout{1} = handle;
end
