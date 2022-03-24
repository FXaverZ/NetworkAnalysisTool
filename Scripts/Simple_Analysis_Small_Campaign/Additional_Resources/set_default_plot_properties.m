function set_default_plot_properties(ax,varargin)
%SET_DEFAULT_PLOT_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here

Fontsize_big     = 16;
Fontsize_normal  = 16;
Fontsize_small   = 12;

axes_on_top = false;

if nargin == 2
	if strcmpi(varargin{1},'axes_on_top')
		axes_on_top = true;
	elseif strcmpi(varargin{1},'axes_to_back')
		axes_on_top = false;
	end
end

ax.FontName                = 'Palatino Linotype';
ax.FontSize                = Fontsize_big;
ax.LabelFontSizeMultiplier = 1;
ax.TitleFontSizeMultiplier = Fontsize_normal/Fontsize_big;
ax.TitleFontWeight         = 'normal';
ax.Box                     = 'off';
ax.LineWidth               = 1;
ax.GridAlphaMode           = 'manual';
ax.MinorGridAlphaMode      = 'manual';
ax.GridAlpha               = 1;
ax.MinorGridAlpha          = 1;
ax.GridColorMode           = 'manual';
ax.MinorGridColorMode      = 'manual';
ax.GridColor               = [217, 217, 217]/256;
ax.MinorGridColor          = [217, 217, 217]/256;
% Legend
lg = get(ax, 'Legend');
if(~isempty(lg))
	lg.FontSize            = Fontsize_small;
	lg.LineWidth           = 1;
	lg.Color               = [1 1 1];
	lg.EdgeColor           = [0 0 0];
	lg.ItemTokenSize       = [10 6];
end
% X Axis
ax.XAxis.TickDirection     = 'out';
ax.XAxis.TickLength        = [0.005 0.0167];
ax.XAxis.FontSize          = Fontsize_normal;
ax.XAxis.LineWidth         = 1.5;
ax.XAxis.Color             = [0 0 0];
ax.XGrid                   = 'on';
% Y Axis
ax.YAxis.TickDirection     = 'out';
ax.YAxis.TickLength        = [0.005 0.00167];
ax.YAxis.FontSize          = Fontsize_normal;
ax.YAxis.LineWidth         = 1.5;
ax.YAxis.Color             = [0 0 0];
ax.XAxis.Color             = [0 0 0];
ax.YGrid                   = 'on';
if axes_on_top
	% (optional) bring axis to front and grid to back:
	ax.Layer                   = 'top';
	pause(0.5);
	ax.XGridHandle.FrontMajorEdge.Layer = 'back';
	ax.XGridHandle.FrontMinorEdge.Layer = 'back';
	pause(0.5);
	ax.YGridHandle.FrontMajorEdge.Layer = 'back';
	ax.YGridHandle.FrontMinorEdge.Layer = 'back';
end
end

