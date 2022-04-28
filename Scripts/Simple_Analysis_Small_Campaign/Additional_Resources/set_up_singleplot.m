function fig = set_up_singleplot(varargin)

fig = figure;

if nargin >= 1 % User gives size wishes
	if strcmpi(varargin{1},'compact')
		pos = [0,89,402,300];     % B: 33% von 'large', H:  8.00 cm -->  4.0cm in Word
	elseif strcmpi(varargin{1},'medium')
		pos = [0,89,602,527];     % B: 50% von 'large', H: 14.00 cm -->  7.0cm in Word
	elseif strcmpi(varargin{1},'large')
		pos = [0,89,1204,602];    % B:100% von 'large', H: 16.00 cm -->  8.0cm in Word
	else
		warning('Not known input!');
	end
else
	pos = [0,89,1204,602];    % H: 16.00 cm -->  8.0cm in Word
end
% pos = [0,89,1280,640];      % H: 17.00 cm --> 8.5 cm in Word

set(gcf,...
	'Unit','Pixel',...
	'Position',pos,...
	'Toolbar','none',...
	'Resize',false);
end

