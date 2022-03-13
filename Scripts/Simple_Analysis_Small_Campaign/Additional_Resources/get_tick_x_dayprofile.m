function [tick_Positions, tick_Labels] = get_tick_x_dayprofile(min_val, step, max_val, label_step)

timescale = 10; % min

tick_Positions = min_val:step/timescale:max_val;
tick_Labels      = cell(1,numel(tick_Positions));

if label_step > 1
	for i = 1 : numel(tick_Positions)
		if mod(i,label_step) == 1
			tick_Labels{i} = datestr(tick_Positions(i)*timescale/1440,'HH:MM');
		else
			tick_Labels{i} = '';
		end
	end
else
	for i = 1 : numel(tick_Positions)
		tick_Labels{i} = datestr(tick_Positions(i)*timescale/1440,'HH:MM');
	end
end


end

