function set_default_plot_properties(ax)
%SET_DEFAULT_PLOT_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here

Fontsize_big     = 14;
Fontsize_normal  = 14;
Fontsize_small   =  8;

ax.FontName                = 'Palatino Linotype';
ax.FontSize                = Fontsize_big;
ax.LabelFontSizeMultiplier = 1;
ax.TitleFontSizeMultiplier = 1;
ax.TitleFontWeight         = 'normal';
ax.Box                     = 'off';
ax.LineWidth               = 1;
ax.GridAlphaMode           = 'manual';
ax.GridAlpha               = 1;
ax.GridColorMode           = 'manual';
ax.GridColor               = [217, 217, 217]/256;
% Legend
lg = get(ax, 'Legend');
if(~isempty(lg))
	lg.FontSize            = Fontsize_small;
	lg.LineWidth           = 1;
end
% X Axis
ax.XAxis.TickDirection     = 'out';
ax.XAxis.TickLength        = [0.0075 0.025];
ax.XAxis.FontSize          = Fontsize_normal;
ax.XAxis.LineWidth         = 1.5;
ax.XGrid                   = 'on';
% Y Axis
ax.YAxis.TickDirection     = 'out';
ax.YAxis.TickLength        = [0.0075 0.025];
ax.YAxis.FontSize          = Fontsize_normal;
ax.YAxis.LineWidth         = 1.5;
ax.YGrid                   = 'on';
end

