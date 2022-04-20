function plot_node_voltage_deviations(handles,Table)
% plot_node_voltage_deviations

% Figure pre-formatting
PlotInput = Table.Values;
% Axis formatting values
PlotXtick = 1 : numel(Table.ColumnName);
PlotXtickLabel = Table.ColumnName;
PlotYLabel = 'Grid voltage deviations (p.u.)';
PlotFigureName = Table.Description;
PlotLegend = Table.RowName;
PlotOffset = [-0.085,0,0.085];
    
% Define figure with computer resolution size
figure('name',PlotFigureName,'Renderer',handles.System.Graphics.Renderer); hold on; grid on; box on
set(gcf,'Position',handles.System.Graphics.Screensize);  % Adjust figure to user screensize
for i = 1 : numel(Table.ColumnName)
    for j = 1 : 3
        line([i+PlotOffset(j),i+PlotOffset(j)],[PlotInput{i}(1,j),PlotInput{i}(3,j)],...
            'LineStyle','-','LineWidth',10,'Color',handles.System.Graphics.Colormap(j+1,:));
    end
    for j = 1 : 3
        line([i+PlotOffset(j),i+PlotOffset(j)],[PlotInput{i}(2,j)*0.995,PlotInput{i}(2,j)*1.005],...
            'LineStyle','-','LineWidth',10,'Color',handles.System.Graphics.Colormap(end,:));
    end
end

% Set axis formatting
set(gca,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize,'XTick',PlotXtick,'XTickLabel',PlotXtickLabel);
ylabel(PlotYLabel,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize);
legend1=legend(PlotLegend,'Location','SouthEast');
set(legend1,'EdgeColor',[1 1 1],...
    'FontName','Times New Roman','Fontsize',handles.System.Graphics.FontSize,'box','off');
hold off;

if numel(Table.ColumnName) == 1
   xlim([0.9,1.1]);
end
% Append temporary data to gcf - append ID for colorscheme control!
setappdata(findobj(gcf,'type','figure'),'FigureID','line_voltage_deviations');

% Append table data to gcf - values
%     setappdata(findobj(gcf,'type','figure'),'table',Table);

end
