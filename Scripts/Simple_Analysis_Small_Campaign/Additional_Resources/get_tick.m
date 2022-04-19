function [tick_Positions, tick_Labels] = get_tick(minVal,step,maxVal,label_step,varargin)

unit = '';
formatstring = [];

if nargin >= 5
	unit = varargin{1};
end
if nargin >= 6
	formatstring = varargin{2};
end

tick_Positions = minVal:step:maxVal;
tick_Labels    = cell(1,numel(tick_Positions));

if label_step > 1
	for i = 1 : numel(tick_Positions)
		if mod(i,label_step) == 1
			if isempty(formatstring)
				tick_Labels{i} = [num2str(tick_Positions(i)),unit];
			else
				tick_Labels{i} = [num2str(tick_Positions(i),formatstring),unit];
			end
		else
			tick_Labels{i} = '';
		end
	end
else
	for i = 1 : numel(tick_Positions)
		if isempty(formatstring)
			tick_Labels{i} = [num2str(tick_Positions(i)),unit];
		else
			tick_Labels{i} = [num2str(tick_Positions(i),formatstring),unit];
		end
	end
end

end

