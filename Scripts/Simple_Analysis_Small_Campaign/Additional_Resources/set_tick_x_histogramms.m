function [tick_x_Positions, tick_x_Labels] = set_tick_x_histogramms(min_Value,max_Value,step_Value,marker, ax)

tick_x_Positions = min_Value+step_Value/2:step_Value:max_Value-step_Value/2;
tick_x_Labels    = cell(1,numel(tick_x_Positions));

for i = 1 : numel(tick_x_Positions)
	if mod(i,marker) == 1
		tick_x_Labels{i} = i-1;
	else
		tick_x_Labels{i} = '';
	end
end

ax.XAxis.Limits       = [min_Value max_Value];
ax.XAxis.TickValues   = tick_x_Positions;
ax.XAxis.TickLabels   = tick_x_Labels;

% minortick_x_Positions = min_Value:step_Value:max_Value;
% ax.XAxis.MinorTickValues = minortick_x_Positions;
% ax.MinorGridLineStyle = '-';
% ax.XGrid = false;
% ax.XMinorGrid = true;

end

