function set_single_plot_properties(ax, titlestr, xlabestr, ylabelstr, show_title)
%SET_SINGLE_PLOT_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here

ax.Title.String = titlestr;
ax.XLabel.String = xlabestr;
ax.YLabel.String = ylabelstr;

if show_title
	ax.Position = [0.06, 0.11, 0.92, 0.83];
else
	ax.Position = [0.06, 0.11, 0.92, 0.86];
end

ax.XLabel.FontWeight = 'bold';
ax.YLabel.FontWeight = 'bold';

end

