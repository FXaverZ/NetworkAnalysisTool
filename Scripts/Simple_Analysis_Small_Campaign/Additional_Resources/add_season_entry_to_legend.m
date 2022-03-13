function [Labels_Text,Labels_Style] = add_season_entry_to_legend(fig_handle,Labels_Text,Labels_Style)

figure(fig_handle);

styles_to_add = {
	'Winter', '-' ;...
	'Sommer', ':';...
	};

for i = 1: size(styles_to_add,1)
% get the legend entries for the grid variants:
Labels_Text{end+1} = styles_to_add{i,1}; %#ok<AGROW>
f_l = plot(nan, nan);	                 % make an invisible line for legend
set(f_l,...
	'Color', 'k',...                     % set color of invisible line
	'LineStyle', styles_to_add{i,2});    % set linestyle of invisible line
Labels_Style(end+1) = f_l;               %#ok<AGROW>
end


end
