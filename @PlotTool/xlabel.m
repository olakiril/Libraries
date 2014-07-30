function varargout = xlabel(varargin)

style = PlotTool.getStyle('xlabel');

if isnumeric(varargin{1})
    handle = xlabel(varargin{1:2},style{:},varargin{3:end});
else
    handle = xlabel(varargin{1},style{:},varargin{2:end});
end

if nargout == 1
    varargout{1} = handle;
end
