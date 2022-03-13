function set_single_plot_properties(ax, titlestr, xlabelstr, ylabelstr, show_title, varargin)
%SET_SINGLE_PLOT_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here
size     = 'large';

if nargin >= 6 % user specifies size of graph
	size = varargin{1};
end

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

switch size
	case 'large'
		% determine the correct size
		if show_title && ~isempty(titlestr)
			Position = [0.06, 0.11, 0.92, 0.83];
		else
			Position = [0.06, 0.11, 0.92, 0.86];
		end
	case 'medium'
		if show_title && ~isempty(titlestr)
			Position = [0.1, 0.11, 0.88, 0.83];
		else
			Position = [0.1, 0.11, 0.88, 0.86];
		end
	case 'compact'
		if show_title && ~isempty(titlestr)
			Position = [0.14, 0.18, 0.82, 0.72];
		else
			if ~isempty(ylabelstr)
				Position = [0.14, 0.18, 0.82, 0.76];
			else
				Position = [0.09, 0.18, 0.88, 0.76];
			end
		end
end

ax.Position = Position;

end

