function Table = plot_current_violation_numbers_overall(handles,Table)
% plot_voltage_violation_numbers_overall

if handles.NVIEW_Processed.Control.Simulation_Options.Number_of_Variants == 1
    return;
end

% Figure pre-formatting
BarhInput = fliplr(Table.Values);
% Axis formatting values
BarhYtick = 1 : numel(Table.ColumnName);
BarhYtickLabel = flipud(Table.ColumnName);
BarhXLabel = Table.Name;
BarhFigureName = Table.Description;

% Define figure with computer resolution size
figure('name',BarhFigureName,'Renderer',handles.System.Graphics.Renderer); hold on; grid on; box on
set(gcf,'Position',handles.System.Graphics.Screensize);  % Adjust figure to user screensize
% Horizontal bar graph
barh(BarhInput','BarLayout','grouped','BarWidth',0.6);
colormap(handles.System.Graphics.Colormap);
set(gca,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize,'YTick',BarhYtick,'YTickLabel',BarhYtickLabel);
xlabel(BarhXLabel,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize);
hold off;

% Append temporary data to gcf - append ID for colorscheme control!
setappdata(findobj(gcf,'type','figure'),'FigureID','barh');

end
