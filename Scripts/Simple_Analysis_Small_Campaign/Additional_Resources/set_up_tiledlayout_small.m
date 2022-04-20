function fig = set_up_tiledlayout_small(titlestr,xlabelstr,ylabelstr,varargin)
%SET_UP_TILEDLAYOUT sets up a tiled figure with title, labes, etc.

Fontsize_big    = 16;

% Values of currently working set up:
%            left,  bottom,    width,  height
% cm:      -33.87,    1.35,    33.87,   24.71
% pixel: -1279.00,   52.00,  1280.00,  934.00
% scr = get(0,'Screensize');

if nargin >= 4 % User gives size wishes
	if strcmpi(varargin{1},'compact')
		pos = [0,89,1204,337];   % H: 9.00 cm -->  4.5.cm in Word
	elseif strcmpi(varargin{1},'medium')
		pos = [0,89,1204,753];   % H: 20.00 cm --> 10.0cm in Word
	elseif strcmpi(varargin{1},'large')
		pos = [0,89,1204,934];   % H: 24.71 cm --> 12.4cm in Word
	else
		warning('Not known input!');
	end
else
	pos = [0,89,1204,337];   % H: 9.00 cm -->  4.5.cm in Word
end
% pos = [0,89,1280,934]; % H: 24.71 cm --> 12.4cm in Word

% create figure:
fig = figure;
set(gcf,...
	'Unit','Pixel',...
	'Position',pos,...
	'Toolbar','none',...
	'Resize',false);

t = tiledlayout(1,4,'TileSpacing', 'none', 'Padding', 'none');

if ~isempty(titlestr)
	title(t,titlestr,...
		'FontName','Palatino Linotype', 'FontSize', Fontsize_big,'FontWeight','bold')
end
if ~isempty(xlabelstr)
	xlabel(t,xlabelstr,...
		'FontName','Palatino Linotype', 'FontSize', Fontsize_big,'FontWeight','bold')
end
if ~isempty(ylabelstr)
	ylabel(t,ylabelstr,...
		'FontName','Palatino Linotype', 'FontSize', Fontsize_big,'FontWeight','bold')
end
end

