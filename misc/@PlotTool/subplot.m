function varargout = subplot(m,n,i,varargin)

style = PlotTool.getStyle('subplot');

if nargin == 1
    handle = subplot(m);
else
    if nargin < 1 || ~isnumeric(m)
        m = 1; n = 1; i = 1;
    end
    handle = subplot(m,n,i,style{:},varargin{:});
end

if nargout == 1
    varargout{1} = handle; 
end
