function [tick_x_Positions, tick_x_Labels] = get_tick_x_profiles(Settings_Number_Profiles)

tick_x_Positions = 0:144/2:144*Settings_Number_Profiles;
tick_x_Labels    = cell(1,numel(tick_x_Positions));

for i = 1 : numel(tick_x_Positions)
	if mod(i,2) == 1
		tick_x_Labels{i} = '';
	else
		tick_x_Labels{i} = i/2;
	end
end

end

