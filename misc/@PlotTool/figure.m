function varargout = figure(varargin)

style = PlotTool.getStyle('figure');

% open or select figure
if nargin < 1 || isempty(varargin{1})
    handle = figure;
elseif ischar(varargin{1})
    handle = figure(style{:},varargin{:});
else
    handle = varargin{1};
    figure(handle)
    set(handle,style{:},varargin{2:end});
end

if nargout == 1
    varargout{1} = handle;
end
