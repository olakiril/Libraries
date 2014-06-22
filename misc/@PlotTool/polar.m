function varargout = polar(varargin)
% Polar plot. For help use:
%   help mmpolar
%   doc mmpolar
%
% AE 2008-10-14

% call mmpolar by D.C. Hanselman
style = PlotTool.getStyle('polar');
[varargout{1:nargout}] = mmpolar(varargin{:},style{:});
