function [Labels_Text,Labels_Style] = add_season_entry_to_legend(fig_handle,linewidth,Labels_Text,Labels_Style,plottype)

figure(fig_handle);

styles_to_add = {
	'Winter', '-' ;...
	'Sommer', ':';...
	};

for i = 1: size(styles_to_add,1)
% get the legend entries for the grid variants:
Labels_Text{end+1} = styles_to_add{i,1}; %#ok<AGROW>
if strcmpi(plottype, 'line')
	invisiblePlot = plot(nan, nan);	               % make an invisible line for legend
	invisiblePlot.Color='k';                         % set color of invisible line
end
if strcmpi(plottype, 'bar')
	invisiblePlot = bar(nan, nan);	                       
	invisiblePlot.EdgeColor = 'k';
	invisiblePlot.FaceColor = 'k';
	invisiblePlot.FaceAlpha = 0.25;
end
invisiblePlot.LineStyle = styles_to_add{i,2}; % set linestyle of invisible line
invisiblePlot.LineWidth = linewidth;
Labels_Style(end+1) = invisiblePlot;               %#ok<AGROW>
end


end
