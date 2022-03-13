function set_single_plot_properties(ax, titlestr, xlabelstr, ylabelstr, show_title, varargin)
%SET_SINGLE_PLOT_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here

if ~isempty(xlabelstr)
	ax.XLabel.String = xlabelstr;
	ax.XLabel.FontWeight = 'bold';
end
if ~isempty(ylabelstr)
	ax.YLabel.String = ylabelstr;
	ax.YLabel.FontWeight = 'bold';
end
if show_title && ~isempty(titlestr)
	ax.Title.String = titlestr;
end

if show_title && ~isempty(titlestr)
	Position = [0.06, 0.11, 0.92, 0.83];
else
	Position = [0.06, 0.11, 0.92, 0.86];
end

ax.Position = Position;

end

