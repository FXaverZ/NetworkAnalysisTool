function  set_tick_x_histogramms(min_Value, max_Value, num_Bins, marker, show_greater_than, ax)
step_Value = (max_Value-min_Value)/num_Bins;
tick_Positions = min_Value+step_Value/2:step_Value:max_Value+step_Value/2;

tick_x_Labels      = {};
main_tick_Position = [];
if marker > 1
	for i = 1 : numel(tick_Positions)
		if mod(i,marker) == 1
			tick_x_Labels{end+1} = tick_Positions(i)-step_Value/2; 
			main_tick_Position(end+1) = tick_Positions(i); 
		end
	end
else
	main_tick_Position = tick_Positions;
	for i = 1 : numel(tick_Positions)
		tick_x_Labels{end+1} = tick_Positions(i)-step_Value/2; %#ok<*AGROW>
	end
end
if show_greater_than && marker > 1
	% Last Label is different, greater than
	main_tick_Position(end) = tick_Positions(end-1);
	tick_x_Labels{end} = ['>',num2str(tick_x_Labels{end})];
	tick_Positions(end) = [];
end

ax.XAxis.Limits       = [min_Value max_Value+step_Value];
ax.XAxis.TickValues   = main_tick_Position;
ax.XAxis.TickLabels   = tick_x_Labels;

ax.XAxis.MinorTickValues = tick_Positions;
ax.XMinorTick = 'on';
ax.MinorGridLineStyle = '-';
ax.XMinorGrid = true;



end

