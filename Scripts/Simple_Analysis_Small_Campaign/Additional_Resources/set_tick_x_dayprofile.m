function set_tick_x_dayprofile(ax, min_val, step, max_val, label_step)

timescale = 10; % min

tick_Positions = min_val:step/timescale:max_val;

tick_Labels      = {};
main_tick_Position = [];
if label_step > 1
	for i = 1 : numel(tick_Positions)
		if mod(i,label_step) == 1
			tick_Labels{end+1} = datestr(tick_Positions(i)*timescale/1440,'HH:MM');
			main_tick_Position(end+1) = tick_Positions(i); 
		end
	end
else
	main_tick_Position = tick_Positions;
	for i = 1 : numel(tick_Positions)
		tick_Labels{end+1} = datestr(tick_Positions(i)*timescale/1440,'HH:MM'); %#ok<*AGROW>
	end
end

ax.XAxis.Limits  = [min_val, max_val];
ax.XAxis.TickValues   = main_tick_Position;
ax.XAxis.TickLabels   = tick_Labels;

ax.XAxis.MinorTickValues = tick_Positions;
ax.XMinorTick = 'on';
ax.MinorGridLineStyle = '-';
ax.XMinorGrid = true;

ax.XAxis.TickLabelRotation = 45;

end

