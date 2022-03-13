function  set_tick_x_histogramms(min_Value,max_Value,num_Bins,marker, ax)
step_Value = (max_Value-min_Value)/num_Bins;
tick_x_Positions = min_Value+step_Value/2:step_Value:max_Value+step_Value/2;

tick_x_Labels      = {};
main_tick_Position = [];
if marker > 1
	for i = 1 : numel(tick_x_Positions)
		if mod(i,marker) == 1
			tick_x_Labels{end+1} = tick_x_Positions(i)-step_Value/2; 
			main_tick_Position(end+1) = tick_x_Positions(i); 
		end
	end
else
	main_tick_Position = tick_x_Positions;
	for i = 1 : numel(tick_x_Positions)
		tick_x_Labels{end+1} = tick_x_Positions(i)-step_Value/2; %#ok<*AGROW>
	end
end

ax.XAxis.Limits       = [min_Value max_Value+step_Value/2];
ax.XAxis.TickValues   = main_tick_Position;
ax.XAxis.TickLabels   = tick_x_Labels;

ax.XAxis.MinorTickValues = tick_x_Positions;
ax.XMinorTick = 'on';
ax.MinorGridLineStyle = '-';
ax.XMinorGrid = true;



end

