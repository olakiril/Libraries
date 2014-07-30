function varargout = ylabel(varargin)

style = PlotTool.getStyle('ylabel');

if isnumeric(varargin{1})
    handle = ylabel(varargin{1:2},style{:},varargin{3:end});
else
    handle = ylabel(varargin{1},style{:},varargin{2:end});
end

if nargout == 1
    varargout{1} = handle;
end
