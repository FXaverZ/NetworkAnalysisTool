function max_area = set_single_plot_properties(ax, titlestr, xlabelstr, ylabelstr, show_title, varargin)
%SET_SINGLE_PLOT_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here

% get the labels correctly
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

% Set the area of the plot axes:
if nargin >= 6 && ~isempty(varargin{1})
	% Working with a given maximum area:
	max_area = varargin{1};
else
	% Maximise area of plot axes:
	max_area = ax.TightInset;
end
ax.Position = [max_area(1:2), 1-max_area(1)-max_area(3), 1-max_area(2)-max_area(4)];

end

