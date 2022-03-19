function [tick_Positions, tick_Labels] = get_tick(minVal,step,maxVal,label_step)

tick_Positions = minVal:step:maxVal;
tick_Labels    = cell(1,numel(tick_Positions));

if label_step > 1
	for i = 1 : numel(tick_Positions)
		if mod(i,label_step) == 1
			tick_Labels{i} = tick_Positions(i);
		else
			tick_Labels{i} = '';
		end
	end
else
	for i = 1 : numel(tick_Positions)
		tick_Labels{i} = tick_Positions(i);
	end
end

end

