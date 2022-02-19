function set_up_tiledlayout(titlestr,xlabestr,ylabelstr)
%SET_UP_TILEDLAYOUT sets up a tiled figure with title, labes, etc.

t = tiledlayout(5,3,'TileSpacing','Compact');
title(t,titlestr,...
	'FontName','Palatino Linotype','FontSize',10)
xlabel(t,xlabestr,...
	'FontName','Palatino Linotype','FontSize',10)
ylabel(t,ylabelstr,...
	'FontName','Palatino Linotype','FontSize',10)
end

