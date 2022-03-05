function set_up_tiledlayout(titlestr,xlabestr,ylabelstr)
%SET_UP_TILEDLAYOUT sets up a tiled figure with title, labes, etc.

Fontsize_big    = 18;

t = tiledlayout(5,3,'TileSpacing', 'compact', 'Padding', 'none');
if ~isempty(titlestr)
	title(t,titlestr,...
		'FontName','Palatino Linotype', 'FontSize', Fontsize_big,'FontWeight','bold')
end
xlabel(t,xlabestr,...
	'FontName','Palatino Linotype', 'FontSize', Fontsize_big)
ylabel(t,ylabelstr,...
	'FontName','Palatino Linotype', 'FontSize', Fontsize_big)
end

