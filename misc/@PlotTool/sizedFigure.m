function varargout = sizedFigure(sizeMm,varargin)
% Figure of given size (in mm)
%   handle = PlotTool.sizedFigure(sizeMm,...) opens a figure that will have the
%   given size when exported/printed. sizeMm is a 2x1 vector of width and height
%   in mm.
%
% AE 2008-07-23

% Compute pixel size
pxPerInch = get(0,'ScreenPixelsPerInch');
mmPerInch = 25.4;
pxPerMm = pxPerInch / mmPerInch;
sizePx = sizeMm * pxPerMm;

% Open/select figure, get position and adjust size
handle = PlotTool.figure(varargin{:});
pos = get(handle,'Position');
moni = get(0,'ScreenSize');
x = round(moni(3)/2) - sizePx(1) ;
y = pos(2) + pos(4) - sizePx(2)+0;
pos = [x y sizePx];
set(handle,'Position',pos,'PaperSize',sizeMm/10,'PaperUnits','centimeters');

% return handle if requested
if nargout > 0
    varargout{1} = handle;
end
