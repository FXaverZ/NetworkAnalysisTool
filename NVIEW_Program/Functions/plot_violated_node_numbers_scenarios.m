function Table = plot_violated_node_numbers_scenarios(handles,Table)
% plot_violated_node_numbers_scenarios

% Figure pre-formatting
BarhInput = fliplr(Table.Values);
% Axis formatting values
BarhYtick = 1 : numel(Table.ColumnName);
BarhYtickLabel = flipud(Table.ColumnName);
BarhXLabel = Table.Name;
BarhLegend = Table.RowName;
BarhLegend = strrep(BarhLegend,'_',' ');

BarhFigureName = Table.Description;

% Define figure with computer resolution size
figure('name',BarhFigureName,'Renderer',handles.System.Graphics.Renderer); hold on; grid on; box on
set(gcf,'Position',handles.System.Graphics.Screensize);  % Adjust figure to user screensize
% Horizontal bar graph
barh(BarhInput','BarLayout','grouped','BarWidth',0.6);
colormap(handles.System.Graphics.Colormap);
set(gca,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize,'YTick',BarhYtick,'YTickLabel',BarhYtickLabel);
xlabel(BarhXLabel,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize);
legend1=legend(BarhLegend,'Location','SouthEast');
set(legend1,'EdgeColor',[1 1 1],'YColor',[1 1 1],'XColor',[1 1 1],...
    'FontName','Times New Roman','Fontsize',handles.System.Graphics.FontSize,'box','off');
hold off;

% Append temporary data to gcf - append ID for colorscheme control!
setappdata(findobj(gcf,'type','figure'),'FigureID','barh');

end