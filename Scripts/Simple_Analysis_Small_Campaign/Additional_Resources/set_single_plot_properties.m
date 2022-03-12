function set_single_plot_properties(ax, titlestr, xlabestr, ylabelstr, show_title)
%SET_SINGLE_PLOT_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here

if ~isempty(xlabestr)
	ax.XLabel.String = xlabestr;
end
if ~isempty(ylabelstr)
	ax.YLabel.String = ylabelstr;
end

if show_title
	if ~isempty(titlestr)
		ax.Title.String = titlestr;
	end
	ax.Position = [0.06, 0.11, 0.92, 0.83];
else
	ax.Position = [0.06, 0.11, 0.92, 0.86];
end

ax.XLabel.FontWeight = 'bold';
ax.YLabel.FontWeight = 'bold';

end

