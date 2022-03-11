function fig = set_up_tiledlayout(titlestr,xlabelstr,ylabelstr)
%SET_UP_TILEDLAYOUT sets up a tiled figure with title, labes, etc.

Fontsize_big    = 14;

% Values of currently working set up:
%            left,  bottom,    width,  height
% cm:      -33.87,    1.35,    33.87,   24.71
% pixel: -1279.00,   52.00,  1280.00,  934.00
% scr = get(0,'Screensize');

pos = [0,89,1280,934];

% create figure:
fig = figure;
set(gcf,...
	'Unit','Pixel',...
	'Position',pos,...
	'Toolbar','none',...
	'Resize',false);

t = tiledlayout(5,3,'TileSpacing', 'compact', 'Padding', 'none');

if ~isempty(titlestr)
	title(t,titlestr,...
		'FontName','Palatino Linotype', 'FontSize', Fontsize_big,'FontWeight','bold')
end
if ~isempty(xlabelstr)
	xlabel(t,xlabelstr,...
		'FontName','Palatino Linotype', 'FontSize', Fontsize_big)
end
if ~isempty(ylabelstr)
	ylabel(t,ylabelstr,...
		'FontName','Palatino Linotype', 'FontSize', Fontsize_big)
end
end

