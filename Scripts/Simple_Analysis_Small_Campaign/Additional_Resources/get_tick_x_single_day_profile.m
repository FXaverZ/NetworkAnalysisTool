function [tick_x_Positions, tick_x_Labels] = get_tick_x_single_day_profile()

tick_x_Positions = 0:6:144;
tick_x_Labels    = cell(1,numel(tick_x_Positions));

for i = 1 : numel(tick_x_Positions)
	if mod(i,2) == 1
		tick_x_Labels{i} = i-1;
	else
		tick_x_Labels{i} = '';
	end
end

end

